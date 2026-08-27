<?php

namespace App\Services;

use App\Models\Trip;
use App\Models\TripStop;
use App\Models\CaptainProfile;
use App\Models\User;
use App\Models\Setting;
use App\Models\Wallet;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Exception;

class TripService
{
    // TTL for pricing settings cache in seconds (15 minutes)
    const PRICING_CACHE_TTL = 900;

    /**
     * Get dynamic search radius in KM from settings.
     */
    public static function getSearchRadiusKm(): float
    {
        return (float) Cache::remember('setting_search_radius_km', self::PRICING_CACHE_TTL,
            fn() => Setting::where('key', 'search_radius_km')->value('value') ?? 10.0);
    }

    protected NotificationService $notificationService;

    public function __construct(?NotificationService $notificationService = null)
    {
        $this->notificationService = $notificationService ?? app(NotificationService::class);
    }

    /**
     * Estimate the price and distance for a trip.
     */
    public function estimate(array $data)
    {
        // Coordinates must be real (validated upstream) – no hardcoded fallbacks
        $distanceKm = $this->calculateDistance(
            (float) $data['pickup_latitude'],
            (float) $data['pickup_longitude'],
            (float) $data['dropoff_latitude'],
            (float) $data['dropoff_longitude']
        );

        $stopsCount = isset($data['stops']) && is_array($data['stops']) ? count($data['stops']) : 0;

        // Pricing pulled dynamically from settings cache
        $perKm = (float) Cache::remember('setting_price_per_km', self::PRICING_CACHE_TTL,
            fn() => Setting::where('key', 'price_per_km')->value('value') ?? 175);

        $multiStopFee = (float) Cache::remember('setting_multi_stop_fee', self::PRICING_CACHE_TTL,
            fn() => Setting::where('key', 'multi_stop_fee')->value('value') ?? 300);

        $rawPrice = ($distanceKm * $perKm) + ($stopsCount * $multiStopFee);
        $estimatedPrice = (int) ceil($rawPrice);

        return [
            'distance_km'     => round($distanceKm, 2),
            'estimated_price' => $estimatedPrice,
            'currency'        => 'YER',
            'applied_rates'   => [
                'per_km_rate'    => $perKm,
                'multi_stop_fee' => $multiStopFee,
                'stops_count'    => $stopsCount,
            ],
        ];
    }

    /**
     * Create a new trip request.
     */
    public function createTrip($userId, array $data)
    {
        return DB::transaction(function () use ($userId, $data) {
            $estimate = $this->estimate($data);

            $trip = Trip::create([
                'user_id' => $userId,
                'promo_code_id' => $data['promo_code_id'] ?? null,
                'type' => $data['type'] ?? 'ride',
                'is_multi_stop' => isset($data['stops']) && count($data['stops']) > 0,
                'pickup_address' => $data['pickup_address'],
                'pickup_latitude' => $data['pickup_latitude'],
                'pickup_longitude' => $data['pickup_longitude'],
                'dropoff_address' => $data['dropoff_address'],
                'dropoff_latitude' => $data['dropoff_latitude'],
                'dropoff_longitude' => $data['dropoff_longitude'],
                'distance_km' => $estimate['distance_km'],
                'estimated_price' => $estimate['estimated_price'],
                'status' => 'pending',
            ]);

            if (isset($data['stops']) && is_array($data['stops'])) {
                foreach ($data['stops'] as $index => $stop) {
                    TripStop::create([
                        'trip_id' => $trip->id,
                        'stop_order' => $index + 1,
                        'address' => $stop['address'] ?? 'موقف إضافي',
                        'latitude' => $stop['latitude'] ?? $data['dropoff_latitude'],
                        'longitude' => $stop['longitude'] ?? $data['dropoff_longitude'],
                    ]);
                }
            }

            $trip->load('stops', 'passenger');

            // Broadcast new trip to nearby captains via WebSockets
            try {
                event(new \App\Events\NewTripRequested($trip));
            } catch (\Exception $e) {}

            // Send FCM push to all online captains
            $this->notifyNearbyCaptains($trip);

            return $trip;
        });
    }

    /**
     * Captain accepts a trip atomically with pessimistic locking.
     * Prevents race conditions when multiple captains accept simultaneously.
     */
    public function acceptTrip($tripId, $captainProfileId)
    {
        return DB::transaction(function () use ($tripId, $captainProfileId) {
            // 1. Zero Debt Policy: Captain cannot accept trips if balance is negative (< 0 YER)
            $captainProfile = CaptainProfile::with('user')->find($captainProfileId);
            if ($captainProfile && $captainProfile->user_id) {
                $wallet = Wallet::where('user_id', $captainProfile->user_id)->first();
                if ($wallet && $wallet->balance < 0.0) {
                    throw new Exception("لا يمكنك قبول مشاوير جديدة لوجود رصيد سالب في محفظتك (" . number_format($wallet->balance) . " ريال). يرجى شحن محفظتك للاستمرار.", 403);
                }
            }

            // 2. Lock row for update so concurrent transactions are serialized
            $trip = Trip::where('id', $tripId)->lockForUpdate()->first();

            if (!$trip) {
                throw new Exception("المشوار المطلوب غير موجود.", 404);
            }

            if ($trip->status !== 'pending') {
                throw new Exception("عذراً، تم قبول هذا المشوار بالفعل من قبل كابتن آخر.", 409);
            }

            $trip->update([
                'captain_profile_id' => $captainProfileId,
                'status' => 'accepted',
                'accepted_at' => now(),
            ]);

            $trip->load(['captain.user', 'passenger', 'stops']);

            // Notify passenger and active channels that captain accepted
            try {
                event(new \App\Events\TripStatusUpdated($trip));
            } catch (\Exception $e) {}

            // Send FCM push to passenger
            if ($trip->passenger) {
                $captainName = $trip->captain?->user?->name ?? 'الكابتن';
                $captainPhone = $trip->captain?->user?->phone ?? '';
                $vehicleModel = $trip->captain?->vehicle_model ?? 'دراجة نارية';
                $vehiclePlate = $trip->captain?->plate_number ?? '';

                $this->notificationService->sendToUser(
                    $trip->passenger,
                    'تم قبول المشوار! 🛵',
                    "الكابتن {$captainName} في طريقه إليك الآن.",
                    [
                        'type' => 'trip_accepted',
                        'status' => 'accepted',
                        'trip_id' => (string) $trip->id,
                        'captain_name' => $captainName,
                        'captain_phone' => $captainPhone,
                        'vehicle_model' => $vehicleModel,
                        'vehicle_plate' => $vehiclePlate,
                        'captain_rating' => (string) ($trip->captain?->rating ?? 5.0),
                    ]
                );
            }

            return $trip;
        });
    }

    /**
     * Captain rejects a trip.
     * Records the rejection and notifies passenger if necessary, or just broadcasts to others.
     */
    public function rejectTrip($tripId, $captainProfileId)
    {
        $trip = Trip::find($tripId);
        if (!$trip) return;
        
        // Broadcast that this captain rejected it so it doesn't stay stuck for them
        // Alternatively, this could just remove it from their nearby pool in Cache
        // In a real production system we'd add to a `trip_rejections` table.
        try {
            event(new \App\Events\TripRejectedByCaptain($tripId, $captainProfileId));
        } catch (\Exception $e) {}
    }

    /**
     * Update trip status (arrived, in_transit, started, completed, cancelled).
     */
    public function updateStatus($tripId, $captainProfileId, $status)
    {
        // Normalize 'started' to 'in_transit' for standard database lifecycle
        if ($status === 'started') {
            $status = 'in_transit';
        }

        return DB::transaction(function () use ($tripId, $captainProfileId, $status) {
            $trip = Trip::where('id', $tripId)
                ->where('captain_profile_id', $captainProfileId)
                ->lockForUpdate()
                ->first();

            if (!$trip) {
                throw new Exception("المشوار غير موجود أو غير مخصص لهذا الكابتن.", 404);
            }

            $validTransitions = [
                'accepted' => ['arrived', 'cancelled'],
                'arrived' => ['in_transit', 'cancelled'],
                'in_transit' => ['completed'],
            ];

            if (!in_array($status, $validTransitions[$trip->status] ?? [])) {
                throw new Exception("تحديث الحالة غير مسموح من الحالة الحالية ({$trip->status}).", 400);
            }

            $updates = ['status' => $status];
            if ($status === 'in_transit') {
                $updates['started_at'] = now();
            } elseif ($status === 'completed') {
                $updates['completed_at'] = now();

                // Calculate final price and commission
                $finalPrice = $trip->estimated_price;

                // Apply promo code discount if any
                if ($trip->promoCode) {
                    if ($trip->promoCode->discount_type === 'percentage') {
                        $discount = $finalPrice * ($trip->promoCode->discount_value / 100);
                        if ($trip->promoCode->max_discount_amount) {
                            $discount = min($discount, $trip->promoCode->max_discount_amount);
                        }
                        $finalPrice -= $discount;
                    } else {
                        $finalPrice -= $trip->promoCode->discount_value;
                    }
                    $finalPrice = max(0, $finalPrice);
                }

                $updates['final_price'] = $finalPrice;

                // Calculate commission from cached settings
                $commissionPercent = (float) Cache::remember('setting_commission_percent', self::PRICING_CACHE_TTL,
                    fn() => Setting::where('key', 'commission_percent')->value('value') ?? 15.0);
                $updates['commission_amount'] = (int) ceil($finalPrice * ($commissionPercent / 100));
                $updates['captain_earnings'] = (int) max(0, floor($finalPrice - $updates['commission_amount']));

                // Deduct commission from Captain's wallet
                if ($trip->captain && $trip->captain->user_id) {
                    $captainUserId = $trip->captain->user_id;

                    $wallet = Wallet::firstOrCreate(
                        ['user_id' => $captainUserId],
                        ['balance' => 0, 'currency' => 'YER']
                    );

                    $wallet->balance -= $updates['commission_amount'];
                    $wallet->save();

                    if ($updates['commission_amount'] > 0) {
                        Transaction::create([
                            'wallet_id' => $wallet->id,
                            'type' => 'withdrawal',
                            'amount' => $updates['commission_amount'],
                            'description' => "عمولة لَفَّة عن المشوار رقم #{$trip->id}"
                        ]);
                    }
                }
            }

            $trip->update($updates);
            $trip->load(['captain.user', 'passenger', 'stops']);

            // Broadcast status update
            try {
                event(new \App\Events\TripStatusUpdated($trip));
            } catch (\Exception $e) {}

            // Send FCM notifications based on status
            if ($trip->passenger) {
                $captainName = $trip->captain?->user?->name ?? 'الكابتن';
                $captainPhone = $trip->captain?->user?->phone ?? '';
                $vehicleModel = $trip->captain?->vehicle_model ?? 'دراجة نارية';
                $vehiclePlate = $trip->captain?->plate_number ?? '';

                if ($status === 'arrived') {
                    $this->notificationService->sendToUser(
                        $trip->passenger,
                        'وصل الكابتن! 📍',
                        "الكابتن {$captainName} وصل إلى موقع الانطلاق وينتظرك الآن.",
                        [
                            'type' => 'trip_arrived',
                            'status' => 'arrived',
                            'trip_id' => (string) $trip->id,
                            'captain_name' => $captainName,
                            'captain_phone' => $captainPhone,
                            'vehicle_model' => $vehicleModel,
                            'vehicle_plate' => $vehiclePlate,
                        ]
                    );
                } elseif ($status === 'in_transit') {
                    $this->notificationService->sendToUser(
                        $trip->passenger,
                        'بدأت الرحلة 🚀',
                        'نتمنى لك رحلة آمنة ومريحة مع لَفَّة.',
                        [
                            'type' => 'trip_started',
                            'status' => 'in_transit',
                            'trip_id' => (string) $trip->id,
                            'captain_name' => $captainName,
                        ]
                    );
                } elseif ($status === 'completed') {
                    $this->notificationService->sendToUser(
                        $trip->passenger,
                        'اكتمل المشوار بنجاح 🎉',
                        "المبلغ المطلوب: " . number_format($trip->final_price) . " ريال. لا تنسَ تقييم الكابتن!",
                        [
                            'type' => 'trip_completed',
                            'status' => 'completed',
                            'trip_id' => (string) $trip->id,
                            'final_price' => (string) $trip->final_price,
                        ]
                    );
                }
            }

            return $trip;
        });
    }

    public function cancelTrip($tripId, User $user, $reason)
    {
        return DB::transaction(function () use ($tripId, $user, $reason) {
            $trip = Trip::where('id', $tripId)->lockForUpdate()->first();

            if (!$trip) {
                throw new Exception("المشوار المطلوب غير موجود.", 404);
            }

            if ($trip->status === 'completed' || $trip->status === 'cancelled') {
                throw new Exception("لا يمكن إلغاء هذه الرحلة لأنها مكتملة أو ملغية مسبقاً.", 400);
            }

            $trip->update([
                'status' => 'cancelled',
                'cancelled_by' => $user->id,
                'cancellation_reason' => $reason,
                'cancelled_at' => now(),
            ]);

            $trip->load(['captain.user', 'passenger', 'stops']);

            // Broadcast cancellation
            try {
                event(new \App\Events\TripStatusUpdated($trip));
            } catch (\Exception $e) {}

            return $trip;
        });
    }

    public function rateTrip($tripId, User $user, $rating, $review)
    {
        $trip = Trip::findOrFail($tripId);

        if ($trip->status !== 'completed') {
            throw new Exception("يمكن تقييم الرحلات المكتملة فقط.", 400);
        }

        if ($user->hasRole('captain')) {
            if ($trip->captain_profile_id !== $user->captainProfile->id) {
                throw new Exception("غير مصرح لك بتقييم هذه الرحلة.", 403);
            }
            $trip->update([
                'rating_by_captain' => $rating,
                'review_by_captain' => $review
            ]);
        } else {
            if ($trip->user_id !== $user->id) {
                throw new Exception("غير مصرح لك بتقييم هذه الرحلة.", 403);
            }
            $trip->update([
                'rating_by_user' => $rating,
                'review_by_user' => $review
            ]);

            // Recalculate captain average rating
            if ($trip->captainProfile) {
                $avgRating = Trip::where('captain_profile_id', $trip->captain_profile_id)
                    ->whereNotNull('rating_by_user')
                    ->avg('rating_by_user');
                if ($avgRating) {
                    $trip->captainProfile->update([
                        'rating' => round($avgRating, 2)
                    ]);
                }
            }
        }

        return $trip;
    }

    /**
     * Send FCM push to all online captains when a new trip is requested.
     */
    private function notifyNearbyCaptains(Trip $trip): void
    {
        try {
            $onlineCaptains = CaptainProfile::where('is_online', true)
                ->whereNotNull('user_id')
                ->with('user')
                ->get();

            foreach ($onlineCaptains as $captain) {
                if ($captain->user) {
                    $this->notificationService->sendToUser(
                        $captain->user,
                        'طلب مشوار جديد! 🛵',
                        "مشوار من {$trip->pickup_address} إلى {$trip->dropoff_address} بقيمة " . number_format($trip->estimated_price) . " ريال",
                        [
                            'type' => 'trip_new',
                            'trip_id' => (string) $trip->id,
                            'pickup' => $trip->pickup_address,
                            'dropoff' => $trip->dropoff_address,
                            'price' => (string) $trip->estimated_price,
                        ]
                    );
                }
            }
        } catch (Exception $e) {
            Log::error("Failed to notify nearby captains for trip #{$trip->id}: " . $e->getMessage());
        }
    }

    /**
     * Accurate Road Distance Calculation.
     * Combines Haversine straight-line distance with an Urban Road Network Detour Factor (1.25x)
     * to realistically reflect street routing and turns in Yemeni cities.
     */
    public function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371; // km
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $straightLineDist = $earthRadius * $c;

        // Apply 1.25x Urban Road Network / Detour Multiplier
        $roadDist = $straightLineDist * 1.25;

        return max($roadDist, 1.0); // Minimum 1 km for calculation
    }
}