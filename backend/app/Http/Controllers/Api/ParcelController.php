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
        ]);

        $size = mb_strtolower(trim($validated['size']));

        $perKm = (float) \Illuminate\Support\Facades\Cache::remember('setting_price_per_km', 3600,
            fn() => Setting::where('key', 'price_per_km')->value('value') ?? 175.00);
        $percentSmall  = (float) \Illuminate\Support\Facades\Cache::remember('setting_parcel_percent_small', 3600,
            fn() => Setting::where('key', 'parcel_percent_small')->value('value') ?? 10.00);
        $percentMedium = (float) \Illuminate\Support\Facades\Cache::remember('setting_parcel_percent_medium', 3600,
            fn() => Setting::where('key', 'parcel_percent_medium')->value('value') ?? 15.00);
        $percentLarge  = (float) \Illuminate\Support\Facades\Cache::remember('setting_parcel_percent_large', 3600,
            fn() => Setting::where('key', 'parcel_percent_large')->value('value') ?? 20.00);

        $tripService = app(\App\Services\TripService::class);
        $distanceKm = $tripService->calculateDistance(
            (float) ($validated['pickup_latitude'] ?? 15.3694),
            (float) ($validated['pickup_longitude'] ?? 44.1910),
            (float) ($validated['dropoff_latitude'] ?? 15.3521),
            (float) ($validated['dropoff_longitude'] ?? 44.2014)
        );

        $sizePercentage = $percentSmall; // 10%
        if (in_array($size, ['medium', 'متوسط'])) {
            $sizePercentage = $percentMedium; // 15%
        } elseif (in_array($size, ['large', 'كبير'])) {
            $sizePercentage = $percentLarge; // 20%
        }

        $distanceCost = $distanceKm * $perKm;
        $calculatedPrice = (int) ceil(round($distanceCost * (1 + ($sizePercentage / 100)), 2));

        $finalPrice = isset($validated['price']) && $validated['price'] > 0
            ? (float) $validated['price']
            : (float) $calculatedPrice;

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

        $parcels = Parcel::where('status', 'pending')
            ->whereNull('captain_profile_id')
            ->with('user')
            ->latest()
            ->take(15)
            ->get();

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
        $parcel = Parcel::where('id', $id)
            ->orWhere('tracking_code', $id)
            ->with(['captain.user', 'user'])
            ->first();

        if (!$parcel) {
            return response()->json([
                'status'  => 'error',
                'message' => 'لم يتم العثور على الطرد المطلوب.',
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
            $parcel = Parcel::where('id', $id)->lockForUpdate()->first();

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

            return response()->json([
                'status'  => 'success',
                'message' => 'تم قبول توصيل الطرد بنجاح!',
                'data'    => $parcel->fresh(['captain.user', 'user']),
            ]);
        });
    }

    /**
     * Update parcel status (picked_up, in_transit, delivered, cancelled).
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:picked_up,in_transit,delivered,cancelled',
        ]);

        $user = $request->user();
        $captainProfile = $user->captainProfile ?? \App\Models\CaptainProfile::where('user_id', $user->id)->first();

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'غير مصرح بهذا الإجراء.'], 403);
        }

        return DB::transaction(function () use ($id, $captainProfile, $request) {
            $parcel = Parcel::where('id', $id)
                ->where('captain_profile_id', $captainProfile->id)
                ->lockForUpdate()
                ->first();

            if (!$parcel) {
                return response()->json(['status' => 'error', 'message' => 'الطرد غير مخصص لهذا الكابتن.'], 404);
            }

            $status = $request->status;
            $updates = ['status' => $status];

            if ($status === 'picked_up') {
                $updates['picked_up_at'] = now();
            } elseif ($status === 'delivered') {
                $updates['delivered_at'] = now();

                // Deduct 15% platform commission from captain wallet
                $commission = round($parcel->price * 0.15, 2);
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

            // Notify parcel owner of status transition
            if ($parcel->user) {
                try {
                    $statusTitles = [
                        'picked_up'  => 'تم استلام الطرد 🛵',
                        'in_transit' => 'الطرد في الطريق إليك 🚀',
                        'delivered'  => 'تم تسليم الطرد بنجاح 🎉',
                        'cancelled'  => 'تم إلغاء توصيل الطرد ❌',
                    ];
                    $statusTitle = $statusTitles[$status] ?? 'تحديث حالة الطرد 📦';

                    $notificationService = app(NotificationService::class);
                    $notificationService->sendToUser(
                        $parcel->user,
                        $statusTitle,
                        "طردك رقم #{$parcel->tracking_code} أصبح الآن في حالة: {$status}",
                        ['type' => 'parcel', 'parcel_id' => (string) $parcel->id, 'status' => $status]
                    );
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