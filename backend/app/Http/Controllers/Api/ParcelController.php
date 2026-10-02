<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Parcel;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Models\Setting;
use App\Services\NotificationService;
use Illuminate\Support\Facades\DB;
use Exception;

class ParcelController extends Controller
{
    /**
     * Request a new parcel delivery.
     */
    public function requestParcel(Request $request)
    {
        $pickupLat = $request->pickup_latitude ?? $request->pickup_lat ?? $request->pickupLatitude;
        $pickupLng = $request->pickup_longitude ?? $request->pickup_lng ?? $request->pickupLongitude;
        $dropoffLat = $request->dropoff_latitude ?? $request->delivery_lat ?? $request->dropoff_lat ?? $request->dropoffLatitude;
        $dropoffLng = $request->dropoff_longitude ?? $request->delivery_lng ?? $request->dropoff_lng ?? $request->dropoffLongitude;
        $parcelType = $request->parcel_type ?? $request->package_type ?? $request->type ?? 'عام';
        $size = $request->size ?? $request->parcel_size ?? 'small';

        $request->merge([
            'pickup_latitude'  => $pickupLat,
            'pickup_longitude' => $pickupLng,
            'dropoff_latitude' => $dropoffLat,
            'dropoff_longitude'=> $dropoffLng,
            'parcel_type'      => $parcelType,
            'size'             => $size,
        ]);

        $validated = $request->validate([
            'sender_name'      => 'required|string|max:100',
            'sender_phone'     => 'required|string|max:20',
            'receiver_name'    => 'required|string|max:100',
            'receiver_phone'   => 'required|string|max:20',
            'pickup_address'   => 'nullable|string|max:255',
            'pickup_latitude'  => 'nullable|numeric|between:12.0,19.5',
            'pickup_longitude' => 'nullable|numeric|between:41.5,54.5',
            'dropoff_address'  => 'nullable|string|max:255',
            'dropoff_latitude' => 'nullable|numeric|between:12.0,19.5',
            'dropoff_longitude'=> 'nullable|numeric|between:41.5,54.5',
            'parcel_type'      => 'required|string|max:50',
            'size'             => 'required|string|max:20',
            'notes'            => 'nullable|string|max:500',
            'price'            => 'nullable|numeric',
            'distance'         => 'nullable|numeric',
        ]);

        $size = mb_strtolower(trim($validated['size']));

        $pickupLat = (float) ($validated['pickup_latitude'] ?? 15.3694);
        $pickupLng = (float) ($validated['pickup_longitude'] ?? 44.1910);
        $dropoffLat = (float) ($validated['dropoff_latitude'] ?? 15.3521);
        $dropoffLng = (float) ($validated['dropoff_longitude'] ?? 44.2014);

        $distanceKm = isset($validated['distance']) && is_numeric($validated['distance'])
            ? (float) $validated['distance']
            : max(0.1, \App\Helpers\GeoHelper::haversineDistance($pickupLat, $pickupLng, $dropoffLat, $dropoffLng));

        $perKm = (float) \Illuminate\Support\Facades\Cache::remember('setting_price_per_km', 3600, fn() => \App\Models\Setting::where('key', 'price_per_km')->value('value') ?? 150);

        $rawPrice = $distanceKm * $perKm;
        
        $sizeFee = 200.0;
        if (in_array($size, ['medium', 'متوسط'])) {
            $sizeFee = 300.0;
        } elseif (in_array($size, ['large', 'كبير'])) {
            $sizeFee = 400.0;
        }

        $isInsuranceEnabled = false;
        if (isset($validated['notes']) && str_contains($validated['notes'], 'شامل التأمين')) {
            $isInsuranceEnabled = true;
        }
        $insuranceFee = $isInsuranceEnabled ? 300.0 : 0.0;

        // Secure final price calculation in backend, ignoring user-supplied values to prevent hijacking
        $finalPrice = (float) ($rawPrice + $sizeFee + $insuranceFee);

        $trackingCode = 'LF-P' . strtoupper(bin2hex(random_bytes(3)));

        $parcel = $request->user()->parcels()->create([
            'sender_name'      => $validated['sender_name'],
            'sender_phone'     => $validated['sender_phone'],
            'receiver_name'    => $validated['receiver_name'],
            'receiver_phone'   => $validated['receiver_phone'],
            'pickup_address'   => $validated['pickup_address'] ?? 'صنعاء',
            'pickup_latitude'  => $validated['pickup_latitude'] ?? 15.3694,
            'pickup_longitude' => $validated['pickup_longitude'] ?? 44.1910,
            'dropoff_address'  => $validated['dropoff_address'] ?? 'صنعاء',
            'dropoff_latitude' => $validated['dropoff_latitude'] ?? 15.3521,
            'dropoff_longitude'=> $validated['dropoff_longitude'] ?? 44.2014,
            'parcel_type'      => $validated['parcel_type'],
            'size'             => $validated['size'],
            'notes'            => $validated['notes'] ?? null,
            'price'            => $finalPrice,
            'status'           => 'pending',
            'tracking_code'    => $trackingCode,
        ]);

        // Broadcast realtime Pusher WebSocket event first for zero delay
        try {
            event(new \App\Events\NewParcelRequested($parcel));
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Failed to broadcast parcel websocket: " . $e->getMessage());
        }

        // Broadcast to nearby online captains (FCM)
        try {
            $notificationService = app(NotificationService::class);

            $onlineCaptains = \App\Models\CaptainProfile::where('is_online', true)->whereNotNull('user_id')->with('user')->get();

            foreach ($onlineCaptains as $captain) {
                // If Redis failed, do a manual distance check fallback
                // Distance check — only notify captains within 15km
                if ($captain->latitude && $captain->longitude) {
                    $earthRadius = 6371;
                    $dLat = deg2rad($parcel->pickup_latitude - $captain->latitude);
                    $dLon = deg2rad($parcel->pickup_longitude - $captain->longitude);
                    $a = sin($dLat/2) * sin($dLat/2) + cos(deg2rad($captain->latitude)) * cos(deg2rad($parcel->pickup_latitude)) * sin($dLon/2) * sin($dLon/2);
                    $dist = $earthRadius * (2 * atan2(sqrt($a), sqrt(1-$a)));
                    if ($dist > 15) continue;
                }

                if ($captain->user) {
                    $notificationService->sendToUser(
                        $captain->user,
                        'طلب إيصال طرد جديد 📦',
                        "طرد جديد من {$parcel->pickup_address} إلى {$parcel->dropoff_address} بقيمة {$parcel->price} ريال",
                        [
                            'type'         => 'new_parcel_request',
                            'parcel_id'    => (string) $parcel->id,
                            'pickup'       => $parcel->pickup_address,
                            'dropoff'      => $parcel->dropoff_address,
                            'price'        => (string) $parcel->price,
                            'sender_name'  => $parcel->sender_name,
                            'sender_phone' => $parcel->sender_phone,
                            'size'         => $parcel->size,
                        ]
                    );
                }
            }
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Failed to broadcast parcel FCM: " . $e->getMessage());
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم إنشاء طلب توصيل الطرد بنجاح!',
            'data'    => $parcel,
        ], 200);
    }

    /**
     * Get list of parcels for authenticated user (passenger or captain).
     */
    public function myParcels(Request $request)
    {
        $user = $request->user();
        $perPage = (int) $request->query('per_page', 20);

        if ($user->hasRole('captain') && $user->captainProfile) {
            $query = Parcel::where('captain_profile_id', $user->captainProfile->id)
                ->with(['captain.user', 'user'])
                ->latest();
        } else {
            $query = $user->parcels()
                ->with(['captain.user', 'user'])
                ->latest();
        }

        $parcels = $query->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data'   => $parcels->items(),
            'pagination' => [
                'current_page' => $parcels->currentPage(),
                'last_page'    => $parcels->lastPage(),
                'per_page'     => $parcels->perPage(),
                'total'        => $parcels->total(),
            ],
        ]);
    }

    /**
     * Get pending parcel requests nearby for online captains.
     */
    public function nearbyRequests(Request $request)
    {
        $user = $request->user();
        $captainProfile = $user->captainProfile;

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'الحساب ليس مسجلاً ككابتن.'], 403);
        }

        // Use DB transaction to prevent race conditions
        $parcels = DB::transaction(function () {
            // 1. Auto-expire pending parcels older than 3 minutes
            $expiredParcels = Parcel::where('status', 'pending')
                ->whereNull('captain_profile_id')
                ->where('created_at', '<', now()->subMinutes(3))
                ->get();
            
            if ($expiredParcels->isNotEmpty()) {
                Parcel::whereIn('id', $expiredParcels->pluck('id'))
                    ->update([
                        'status' => 'cancelled',
                        'notes' => 'انتهت مهلة انتظار الكابتن (3 دقائق)',
                    ]);
            }

            // 2. Query only fresh, pending, unassigned parcels
            return Parcel::where('status', 'pending')
                ->whereNull('captain_profile_id')
                ->where('created_at', '>=', now()->subMinutes(3))
                ->with('user')
                ->latest()
                ->take(30) // Get more since we will filter in PHP
                ->get();
        });

        // 3. Filter by distance (15km radius)
        $lat = $request->input('lat') ?? $request->input('latitude') ?? $captainProfile->latitude;
        $lng = $request->input('lng') ?? $request->input('longitude') ?? $captainProfile->longitude;

        if ($lat && $lng) {
            $parcels = $parcels->filter(function ($parcel) use ($lat, $lng) {
                if (!$parcel->pickup_latitude || !$parcel->pickup_longitude) return true;
                
                $dist = \App\Helpers\GeoHelper::haversineDistance($parcel->pickup_latitude, $parcel->pickup_longitude, $lat, $lng);
                
                return $dist <= 15.0; 
            })->values();
        }

        return response()->json([
            'status' => 'success',
            'data'   => $parcels,
        ]);
    }

    /**
     * Track a parcel by ID or tracking number/code.
     */
    public function trackParcel(Request $request, $id)
    {
        $user = $request->user();
        
        $parcel = Parcel::where(function ($q) use ($id) {
                $q->where('id', $id)
                  ->orWhere('tracking_code', $id);
            })
            ->where(function ($q) use ($user) {
                // Must be the owner or the assigned captain
                $q->where('user_id', $user->id);
                
                if ($user->captainProfile) {
                    $q->orWhere('captain_profile_id', $user->captainProfile->id);
                }
            })
            ->with(['captain.user', 'user'])
            ->first();

        if (!$parcel) {
            return response()->json([
                'status'  => 'error',
                'message' => 'لم يتم العثور على الطرد المطلوب أو ليس لديك صلاحية الوصول إليه.',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $parcel,
        ]);
    }

    /**
     * Captain accepts a pending parcel delivery.
     */
    public function acceptParcel(Request $request, $id)
    {
        $user = $request->user();
        $captainProfile = $user->captainProfile ?? \App\Models\CaptainProfile::where('user_id', $user->id)->first();

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'الحساب ليس مسجلاً ككابتن.'], 403);
        }

        return DB::transaction(function () use ($id, $captainProfile, $user) {
            $parcel = Parcel::where(function ($q) use ($id) {
                $q->where('id', $id)
                  ->orWhere('tracking_code', $id);
            })->lockForUpdate()->first();

            if (!$parcel) {
                return response()->json(['status' => 'error', 'message' => 'الطرد غير موجود.'], 404);
            }

            if ($parcel->status !== 'pending') {
                return response()->json(['status' => 'error', 'message' => 'تم قبول هذا الطرد مسبقاً من كابتن آخر.'], 409);
            }

            $parcel->update([
                'captain_profile_id' => $captainProfile->id,
                'status'             => 'accepted',
                'accepted_at'        => now(),
            ]);

            try {
                event(new \App\Events\ParcelStatusUpdated($parcel));
            } catch (\Exception $e) {}

            // Notify parcel owner
            if ($parcel->user) {
                try {
                    $notificationService = app(NotificationService::class);
                    $notificationService->sendToUser(
                        $parcel->user,
                        'تم قبول طلب توصيل الطرد 📦',
                        "وافق الكابتن {$user->name} على توصيل طردك #{$parcel->tracking_code}.",
                        ['type' => 'parcel', 'parcel_id' => (string) $parcel->id]
                    );
                } catch (\Exception $e) {}
            }

            // Notify captain
            try {
                $notificationService = app(NotificationService::class);
                $notificationService->sendToUser(
                    $user,
                    'تم قبول توصيل الطرد 📦',
                    "مشوار توصيل طرد جديد #{$parcel->tracking_code} بقيمة " . number_format($parcel->price) . " ر.ي.",
                    ['type' => 'parcel', 'parcel_id' => (string) $parcel->id]
                );
            } catch (\Exception $e) {}

            return response()->json([
                'status'  => 'success',
                'message' => 'تم قبول توصيل الطرد بنجاح!',
                'data'    => $parcel->fresh(['captain.user', 'user']),
            ]);
        });
    }

    /**
     * Update parcel status (arrived_at_pickup, picked_up, in_transit, delivered, cancelled).
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:arrived_at_pickup,arrived,picked_up,in_transit,delivered,cancelled',
        ]);

        $user = $request->user();
        $captainProfile = $user->captainProfile ?? \App\Models\CaptainProfile::where('user_id', $user->id)->first();

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'غير مصرح بهذا الإجراء.'], 403);
        }

        return DB::transaction(function () use ($id, $captainProfile, $request, $user) {
            $parcel = Parcel::where(function ($q) use ($id) {
                    $q->where('id', $id)
                      ->orWhere('tracking_code', $id);
                })
                ->where(function ($q) use ($captainProfile) {
                    $q->where('captain_profile_id', $captainProfile->id)
                      ->orWhereNull('captain_profile_id');
                })
                ->lockForUpdate()
                ->first();

            if (!$parcel) {
                return response()->json(['status' => 'error', 'message' => 'الطرد غير مخصص لهذا الكابتن أو غير موجود.'], 404);
            }

            $status = $request->status;
            if ($status === 'arrived') {
                $status = 'arrived_at_pickup';
            }

            $updates = [
                'status' => $status,
                'captain_profile_id' => $captainProfile->id,
            ];

            if ($status === 'arrived_at_pickup') {
                $updates['arrived_at_pickup_at'] = now();
            } elseif ($status === 'picked_up') {
                $updates['picked_up_at'] = now();
            } elseif ($status === 'delivered') {
                $updates['delivered_at'] = now();

                // Deduct platform commission from captain wallet (read from settings)
                $commissionPercent = (float) \Illuminate\Support\Facades\Cache::remember('setting_commission_percent', 3600, fn() => \App\Models\Setting::where('key', 'commission_percent')->value('value') ?? 15);
                $commission = round($parcel->price * ($commissionPercent / 100), 2);
                $wallet = Wallet::firstOrCreate(['user_id' => $captainProfile->user_id], ['balance' => 0, 'currency' => 'YER']);
                $wallet->balance -= $commission;
                $wallet->save();

                Transaction::create([
                    'wallet_id'   => $wallet->id,
                    'type'        => 'withdrawal',
                    'amount'      => $commission,
                    'description' => "عمولة لَفَّة عن توصيل طرد #{$parcel->tracking_code}",
                ]);
            }

            $parcel->update($updates);

            try {
                event(new \App\Events\ParcelStatusUpdated($parcel));
            } catch (\Exception $e) {}

            // Notify parcel owner of status transition
            if ($parcel->user) {
                try {
                    $statusMessages = [
                        'arrived_at_pickup' => [
                            'title' => 'الكابتن وصل إلى موقع الاستلام 📍',
                            'body'  => "وصل الكابتن {$user->name} إلى موقع الاستلام وبانتظار تسليم الطرد #{$parcel->tracking_code}."
                        ],
                        'picked_up' => [
                            'title' => 'تم استلام الطرد بنجاح 📦',
                            'body'  => "قام الكابتن {$user->name} بفحص واستلام طردك #{$parcel->tracking_code} وجاري تجهيز الانطلاق."
                        ],
                        'in_transit' => [
                            'title' => 'الشحنة في الطريق إلى الوجهة 🛵',
                            'body'  => "الكابتن في طريقه الآن إلى موقع التسليم ({$parcel->dropoff_address})."
                        ],
                        'delivered' => [
                            'title' => 'تم تسليم الطرد بنجاح 🎉',
                            'body'  => "تم تسليم الشحنة #{$parcel->tracking_code} بنجاح إلى المستلم ({$parcel->receiver_name}). شكراً لاختيارك لَفَّة!"
                        ],
                        'cancelled' => [
                            'title' => 'تم إلغاء توصيل الطرد ❌',
                            'body'  => "تم إلغاء طلب توصيل الطرد #{$parcel->tracking_code}."
                        ],
                    ];

                    $msg = $statusMessages[$status] ?? [
                        'title' => 'تحديث حالة الطرد 📦',
                        'body'  => "طردك رقم #{$parcel->tracking_code} أصبح الآن في حالة: {$status}"
                    ];

                    // Send FCM for all parcel status updates to ensure passenger is kept informed
                    $shouldSendFcm = in_array($status, ['arrived_at_pickup', 'picked_up', 'in_transit', 'delivered', 'cancelled']);

                    if ($shouldSendFcm) {
                        $notificationService = app(NotificationService::class);
                        $notificationService->sendToUser(
                            $parcel->user,
                            $msg['title'],
                            $msg['body'],
                            [
                                'type' => 'parcel',
                                'parcel_id' => (string) $parcel->id,
                                'status' => $status,
                                'tracking_code' => (string) $parcel->tracking_code,
                            ]
                        );
                    }

                    // If delivered, notify captain of earnings
                    if ($status === 'delivered') {
                        $captainEarning = number_format($parcel->price * 0.85);
                        $notificationService->sendToUser(
                            $user,
                            'تم تسليم الطرد بنجاح 🎉',
                            "أحسنت! تم تسليم الطرد #{$parcel->tracking_code} بنجاح وإيداع صافي أرباحك ({$captainEarning} ر.ي) في محفظتك.",
                            [
                                'type' => 'parcel_delivered',
                                'status' => 'delivered',
                                'parcel_id' => (string) $parcel->id,
                                'tracking_code' => (string) $parcel->tracking_code,
                            ]
                        );
                    }
                } catch (\Exception $e) {}
            }

            return response()->json([
                'status'  => 'success',
                'message' => 'تم تحديث حالة الطرد بنجاح.',
                'data'    => $parcel->fresh(['captain.user', 'user']),
            ]);
        });
    }
}