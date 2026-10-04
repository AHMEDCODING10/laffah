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
    const CACHE_TTL = 300; // 5 minutes
    const PRICING_CACHE_TTL = 3600; // 1 hour for settings
    const MAX_CAPTAIN_DEBT = -3000; // Maximum allowed negative balance before blocking

    protected $notificationService;
    protected $walletService;

    public function __construct(
        ?NotificationService $notificationService = null,
        ?WalletService $walletService = null
    ) {
        $this->notificationService = $notificationService ?? app(NotificationService::class);
        $this->walletService = $walletService ?? app(WalletService::class);
    }

    /**
     * Estimate the price and distance for a trip.
     */
    public function estimate(array $data)
    {
        $stopsCount = isset($data['stops']) && is_array($data['stops']) ? count($data['stops']) : 0;

        // [PERFORMANCE FIX P0-04]: Calculate distance via single multi-point OSRM call with caching
        if (!isset($data['distance']) || !is_numeric($data['distance'])) {
            $waypoints = [
                ['lat' => (float) $data['pickup_latitude'], 'lng' => (float) $data['pickup_longitude']]
            ];

            if ($stopsCount > 0) {
                foreach ($data['stops'] as $stop) {
                    $waypoints[] = [
                        'lat' => (float) ($stop['latitude'] ?? $data['pickup_latitude']),
                        'lng' => (float) ($stop['longitude'] ?? $data['pickup_longitude']),
                    ];
                }
            }

            $waypoints[] = [
                'lat' => (float) $data['dropoff_latitude'],
                'lng' => (float) $data['dropoff_longitude']
            ];

            $osrmService = app(\App\Services\OSRMService::class);
            $routeDetails = $osrmService->getMultiPointRouteDetails($waypoints);
            $distanceKm = max(1.0, (float) ($routeDetails['distance'] ?? 1.0));
        } else {
            $distanceKm = max(1.0, (float) $data['distance']);
        }

        // --- All pricing pulled exclusively from the settings cache ---
        $perKm = (float) Cache::remember('setting_price_per_km', self::PRICING_CACHE_TTL,
            fn() => Setting::where('key', 'price_per_km')->value('value') ?? 150);
        $stopFeePerStop = (float) Cache::remember('setting_multi_stop_fee', self::PRICING_CACHE_TTL,
            fn() => Setting::where('key', 'multi_stop_fee')->value('value') ?? 200.0);
        $totalStopFees = $stopsCount * $stopFeePerStop;

        // Calculate clean price based on exact distance, rate per km, and multi-stop fee
        $rawPrice = ($distanceKm * $perKm) + $totalStopFees;
        $grossPrice = (int) max(500, ceil($rawPrice)); // Standard minimum fare 500 YER
        $estimatedPrice = $grossPrice;

        // [BUSINESS LOGIC FIX ISSUE-3.5]: Optional promo code discount estimation
        $discountAmount = 0;
        $promoCodeId = $data['promo_code_id'] ?? null;
        if (!$promoCodeId && !empty($data['promo_code'])) {
            $promoCodeId = \App\Models\PromoCode::where('code', trim($data['promo_code']))->value('id');
        }
        if ($promoCodeId) {
            $promo = \App\Models\PromoCode::find($promoCodeId);
            if ($promo && $promo->isValid()) {
                $discountAmount = (int) round($promo->calculateDiscount($grossPrice));
                $estimatedPrice = max(0, $grossPrice - $discountAmount);
            }
        }

        $lat = (float) $data['pickup_latitude'];
        $lng = (float) $data['pickup_longitude'];

        // Get nearby captains sorted Nearest-First with 15-minute freshness check (max 4.5km economic limit)
        $nearbyCaptains = $this->getNearbyCaptainsSorted($lat, $lng, 4.5, 15);
        $nearbyCaptainsCount = $nearbyCaptains->count();

        // If strict 4.5km yields 0, check active online captains in the service pool
        if ($nearbyCaptainsCount === 0) {
            $onlinePool = \App\Models\CaptainProfile::where('is_online', true)->count();
            if ($onlinePool > 0) {
                $nearbyCaptainsCount = min($onlinePool, 5);
            }
        }

        // Dynamic ETA calculation to pickup:
        // Nearest captain distance (km) / avg city speed 20km/h * 60 min + 1 min buffer
        $nearestDist = $nearbyCaptains->first()?->distance_km;
        $captainEtaMinutes = $nearestDist !== null
            ? max(2, (int) round(($nearestDist / 20.0) * 60) + 1)
            : 4;

        return [
            'distance_km'         => round($distanceKm, 2),
            'gross_price'         => $grossPrice,
            'discount_amount'     => $discountAmount,
            'estimated_price'     => $estimatedPrice,
            'currency'            => 'YER',
            'nearby_captains'     => $nearbyCaptainsCount,
            'captain_eta_minutes' => $captainEtaMinutes,
            // Applied rates returned for client-side display/debug
            'applied_rates'       => [
                'base_fare'       => 0.0,
                'per_km_rate'     => $perKm,
                'min_fare'        => 500.0,
                'multi_stop_fee'  => $stopFeePerStop,
                'stops_count'     => $stopsCount,
                'total_stop_fees' => $totalStopFees,
            ],
        ];
    }

    /**
     * Get nearby online captains sorted by proximity (nearest-first)
     * with location freshness filtering (heartbeat).
     *
     * @param float $lat
     * @param float $lng
     * @param float $radiusKm (default 4.5)
     * @param int $freshMinutes
     * @return \Illuminate\Support\Collection
     */
    public function getNearbyCaptainsSorted(float $lat, float $lng, float $radiusKm = 4.5, int $freshMinutes = 15)
    {
        $latDelta = $radiusKm / 111.0;
        $lngDelta = $radiusKm / (111.0 * max(0.1, cos(deg2rad($lat))));
        $haversine = "(6371 * acos(cos(radians($lat)) * cos(radians(captain_locations.latitude)) * cos(radians(captain_locations.longitude) - radians($lng)) + sin(radians($lat)) * sin(radians(captain_locations.latitude))))";

        // Primary search: online captains with recent GPS heartbeat within radius
        $captains = DB::table('captain_locations')
            ->join('captain_profiles', 'captain_locations.captain_profile_id', '=', 'captain_profiles.id')
            ->where('captain_profiles.is_online', true)
            ->whereBetween('captain_locations.latitude', [$lat - $latDelta, $lat + $latDelta])
            ->whereBetween('captain_locations.longitude', [$lng - $lngDelta, $lng + $lngDelta])
            ->where('captain_locations.last_updated_at', '>=', now()->subMinutes($freshMinutes))
            ->whereRaw("$haversine <= ?", [$radiusKm])
            ->select(
                'captain_profiles.id as captain_profile_id',
                'captain_profiles.user_id',
                'captain_locations.latitude',
                'captain_locations.longitude',
                'captain_locations.last_updated_at',
                DB::raw("$haversine as distance_km")
            )
            ->orderBy('distance_km', 'asc')
            ->get();

        // Fallback: If no captains updated within freshMinutes, relax freshness filter to include all online captains with coordinates
        if ($captains->isEmpty()) {
            $captains = DB::table('captain_locations')
                ->join('captain_profiles', 'captain_locations.captain_profile_id', '=', 'captain_profiles.id')
                ->where('captain_profiles.is_online', true)
                ->whereBetween('captain_locations.latitude', [$lat - $latDelta, $lat + $latDelta])
                ->whereBetween('captain_locations.longitude', [$lng - $lngDelta, $lng + $lngDelta])
                ->whereRaw("$haversine <= ?", [$radiusKm])
                ->select(
                    'captain_profiles.id as captain_profile_id',
                    'captain_profiles.user_id',
                    'captain_locations.latitude',
                    'captain_locations.longitude',
                    'captain_locations.last_updated_at',
                    DB::raw("$haversine as distance_km")
                )
                ->orderBy('distance_km', 'asc')
                ->get();
        }

        return $captains;
    }

    /**
     * Create a new trip request.
     */
    public function createTrip($userId, array $data)
    {
        return DB::transaction(function () use ($userId, $data) {
            // [BUSINESS LOGIC FIX ISSUE-3.5]: Validate promo code if provided
            $promoCodeId = $data['promo_code_id'] ?? null;
            if (!$promoCodeId && !empty($data['promo_code'])) {
                $promoCodeId = \App\Models\PromoCode::where('code', trim($data['promo_code']))->value('id');
            }
            if ($promoCodeId) {
                $promo = \App\Models\PromoCode::find($promoCodeId);
                if (!$promo || !$promo->isValid()) {
                    throw new \Exception("كود الخصم المحدد غير صالح أو منتهي الصلاحية أو تم استنفاد الحد الأقصى لاستخدامه.", 422);
                }
            }

            $estimate = $this->estimate($data);
            
            $paymentMethod = $data['payment_method'] ?? 'cash';
            
            // If payment method is wallet, check balance & hold escrow (ISSUE-3.2)
            if ($paymentMethod === 'wallet') {
                $wallet = \App\Models\Wallet::where('user_id', $userId)->lockForUpdate()->first();
                $available = $wallet ? ($wallet->balance - ($wallet->held_balance ?? 0.0)) : 0.0;
                if (!$wallet || $available < $estimate['estimated_price']) {
                    throw new \Exception("رصيد المحفظة المتاح غير كافٍ لتغطية المشوار (" . number_format($available) . " ريال). يرجى شحن الرصيد أو اختيار الدفع نقداً.", 402);
                }
                // Escrow hold to prevent double-spending
                $wallet->held_balance = ($wallet->held_balance ?? 0.0) + $estimate['estimated_price'];
                $wallet->save();
            }

            $trip = Trip::create([
                'user_id' => $userId,
                'promo_code_id' => $promoCodeId,
                'type' => $data['type'] ?? 'ride',
                'payment_method' => $paymentMethod,
                'is_multi_stop' => isset($data['stops']) && count($data['stops']) > 0,
                'pickup_address' => $data['pickup_address'],
                'pickup_latitude' => $data['pickup_latitude'],
                'pickup_longitude' => $data['pickup_longitude'],
                'dropoff_address' => $data['dropoff_address'],
                'dropoff_latitude' => $data['dropoff_latitude'],
                'dropoff_longitude' => $data['dropoff_longitude'],
                'distance_km' => $estimate['distance_km'],
                'estimated_price' => $estimate['estimated_price'],
                'status' => (isset($data['is_scheduled']) && $data['is_scheduled']) ? 'scheduled' : 'pending',
                'is_scheduled' => $data['is_scheduled'] ?? false,
                'scheduled_time' => isset($data['scheduled_time']) ? \Carbon\Carbon::parse($data['scheduled_time']) : null,
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

            if ($trip->is_scheduled) {
                // Return immediately without broadcasting if it's a scheduled trip
                return $trip;
            }

            // [PERFORMANCE FIX ISSUE-1.7]: Run broadcasting and notifications AFTER transaction commit
            DB::afterCommit(function () use ($trip) {
                try {
                    // Broadcast realtime Pusher WebSocket event first for zero delay
                    event(new \App\Events\NewTripRequested($trip));

                    // Notify all online captains about the new trip (FCM)
                    $this->notifyNearbyCaptains($trip);
                } catch (\Throwable $e) {
                    \Log::error('Trip created broadcast/notification error: ' . $e->getMessage());
                }
            });

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
            // 1. Verify Captain does not exceed negative debt threshold
            $captainProfile = CaptainProfile::with('user')->find($captainProfileId);
            if ($captainProfile && $captainProfile->user_id) {
                $wallet = Wallet::where('user_id', $captainProfile->user_id)->first();
                if ($wallet && $wallet->balance < self::MAX_CAPTAIN_DEBT) {
                    throw new Exception("لا يمكنك قبول مشاوير جديدة لتجاوز سقف العمولة المستحقة (" . number_format($wallet->balance) . " ريال). يرجى شحن محفظتك للاستمرار.", 403);
                }
            }

            // 2. Lock row for update so concurrent transactions are serialized
            $trip = Trip::where('id', $tripId)->lockForUpdate()->first();

            if (!$trip) {
                throw new Exception("المشوار المطلوب غير موجود.", 404);
            }

            if ($trip->status !== 'pending') {
                if ($trip->status === 'cancelled') {
                    throw new Exception("عذراً، تم إلغاء هذا المشوار من قبل الراكب أو لانتهاء مهلة البحث.", 410);
                }
                throw new Exception("عذراً، تم قبول هذا المشوار بالفعل من قبل كابتن آخر.", 409);
            }



            $trip->update([
                'captain_profile_id' => $captainProfileId,
                'status' => 'accepted',
                'accepted_at' => now(),
            ]);

            $trip->load(['captain.user', 'passenger', 'stops']);

            // [PERFORMANCE FIX ISSUE-1.7]: Run broadcasting and notifications AFTER transaction commit
            DB::afterCommit(function () use ($trip) {
                try {
                    // Notify passenger and active channels that captain accepted
                    event(new \App\Events\TripStatusUpdated($trip));
                } catch (\Throwable $e) {}

                // Send FCM push to passenger
                if ($trip->passenger) {
                    $captainName = $trip->captain?->user?->name ?? 'الكابتن';
                    $captainPhone = $trip->captain?->user?->phone ?? '';
                    $vehicleModel = $trip->captain?->vehicle_model ?? 'دراجة نارية';
                    $vehiclePlate = $trip->captain?->plate_number ?? '';

                    try {
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
                    } catch (\Throwable $e) {
                        \Log::error('AcceptTrip FCM error: ' . $e->getMessage());
                    }
                }
            });

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
        if (!$trip || $trip->status !== 'pending') return;
        
        $captain = CaptainProfile::find($captainProfileId);
        if (!$captain) return;
        
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
        // Normalize status aliases
        if (in_array($status, ['arrived_at_pickup', 'arrived'])) {
            $status = 'arrived';
        } elseif (in_array($status, ['started', 'in_progress', 'in_transit'])) {
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

                // Calculate gross price strictly based on exact DB settings, distance, and multi-stop fee (ISSUE-3.4)
                $perKm = (float) Cache::remember('setting_price_per_km', self::PRICING_CACHE_TTL, fn() => Setting::where('key', 'price_per_km')->value('value') ?? 150);
                $stopFeePerStop = (float) Cache::remember('setting_multi_stop_fee', self::PRICING_CACHE_TTL, fn() => Setting::where('key', 'multi_stop_fee')->value('value') ?? 200.0);
                $stopsCount = $trip->stops()->count();
                $totalStopFees = $stopsCount * $stopFeePerStop;

                $rawPrice = ($trip->distance_km * $perKm) + $totalStopFees;
                $grossPrice = (int) max(500, ceil($rawPrice)); // Standard minimum fare

                // Calculate platform commission from cached settings based on GROSS price
                $commissionPercent = (float) Cache::remember('setting_commission_percent', self::PRICING_CACHE_TTL,
                    fn() => Setting::where('key', 'commission_percent')->value('value') ?? 15.0);
                $commissionAmount = (int) ceil($grossPrice * ($commissionPercent / 100));

                // [FINANCIAL FIX ISSUE-3.3]: Captain earnings are calculated on GROSS fare, NOT penalized by promos!
                $captainEarnings = (int) max(0, $grossPrice - $commissionAmount);

                // Apply promo code discount to passenger's bill [FINANCIAL FIX ISSUE-3.5]
                $finalPrice = $grossPrice;
                if ($trip->promo_code_id) {
                    $promo = \App\Models\PromoCode::where('id', $trip->promo_code_id)->lockForUpdate()->first();
                    if ($promo && $promo->isValid()) {
                        $discount = $promo->calculateDiscount($grossPrice);
                        $finalPrice = (int) max(0, round($grossPrice - $discount));
                        $promo->increment('used_count');
                    }
                }

                $updates['final_price'] = $finalPrice;
                $updates['commission_amount'] = $commissionAmount;
                $updates['captain_earnings'] = $captainEarnings;

                // Handle Payments
                if ($trip->payment_method === 'wallet') {
                    // [ESCROW SETTLEMENT FIX ISSUE-3.2]: Deduct passenger wallet & release held_balance
                    $passengerWallet = Wallet::where('user_id', $trip->user_id)->lockForUpdate()->first();
                    if ($passengerWallet) {
                        $heldToRelease = min((float) ($passengerWallet->held_balance ?? 0.0), (float) ($trip->estimated_price ?? $grossPrice));
                        $passengerWallet->held_balance = max(0.0, (float) ($passengerWallet->held_balance ?? 0.0) - $heldToRelease);
                        $passengerWallet->balance -= $finalPrice;
                        $passengerWallet->save();

                        if ($finalPrice > 0) {
                            Transaction::create([
                                'wallet_id'   => $passengerWallet->id,
                                'trip_id'     => $trip->id,
                                'type'        => 'withdrawal',
                                'amount'      => $finalPrice,
                                'status'      => 'completed',
                                'description' => "دفع قيمة المشوار رقم #{$trip->id}" . ($trip->promoCode ? " (بعد خصم ترويجي)" : ""),
                            ]);
                        }
                    }

                    // 2. Add net earnings to Captain's wallet
                    if ($trip->captain && $trip->captain->user_id) {
                        $captainWallet = Wallet::firstOrCreate(
                            ['user_id' => $trip->captain->user_id],
                            ['balance' => 0.0, 'held_balance' => 0.0, 'currency' => 'YER']
                        );
                        $captainWallet = Wallet::where('id', $captainWallet->id)->lockForUpdate()->first();
                        $captainWallet->balance += $captainEarnings;
                        $captainWallet->save();

                        if ($captainEarnings > 0) {
                            Transaction::create([
                                'wallet_id'   => $captainWallet->id,
                                'trip_id'     => $trip->id,
                                'type'        => 'deposit',
                                'amount'      => $captainEarnings,
                                'status'      => 'completed',
                                'description' => "أرباح المشوار رقم #{$trip->id} (محفظة)"
                            ]);
                        }
                    }
                } else {
                    // Default Cash flow: Captain took the cash, platform deducts commission
                    if ($trip->captain && $trip->captain->user_id) {
                        $captainWallet = Wallet::firstOrCreate(
                            ['user_id' => $trip->captain->user_id],
                            ['balance' => 0.0, 'held_balance' => 0.0, 'currency' => 'YER']
                        );
                        $captainWallet = Wallet::where('id', $captainWallet->id)->lockForUpdate()->first();
                        $captainWallet->balance -= $commissionAmount;
                        $captainWallet->save();

                        if ($commissionAmount > 0) {
                            Transaction::create([
                                'wallet_id'   => $captainWallet->id,
                                'trip_id'     => $trip->id,
                                'type'        => 'commission',
                                'amount'      => $commissionAmount,
                                'status'      => 'completed',
                                'description' => "عمولة لَفَّة عن المشوار رقم #{$trip->id} (نقداً)"
                            ]);
                        }
                    }
                }
            }

            $trip->update($updates);
            $trip->load(['captain.user', 'passenger', 'stops']);

            // [PERFORMANCE FIX ISSUE-1.7]: Run broadcasting and notifications AFTER transaction commit
            DB::afterCommit(function () use ($trip, $status) {
                try {
                    event(new \App\Events\TripStatusUpdated($trip));
                } catch (\Throwable $e) {}

                if ($trip->passenger) {
                    if ($status === 'completed') {
                        try {
                            $this->notificationService->sendToUser(
                                $trip->passenger,
                                'اكتمل المشوار بنجاح 🎉',
                                "المبلغ المطلوب: " . number_format($trip->final_price) . " ريال. لا تنسَ تقييم الكابتن!",
                                [
                                    'type'        => 'trip_completed',
                                    'status'      => 'completed',
                                    'trip_id'     => (string) $trip->id,
                                    'final_price' => (string) $trip->final_price,
                                ]
                            );
                        } catch (\Throwable $e) {}
                    }
                }

                if ($status === 'completed' && $trip->captain && $trip->captain->user) {
                    $earning = number_format($trip->captain_earnings ?? 0);
                    try {
                        $this->notificationService->sendToUser(
                            $trip->captain->user,
                            'تم إنهاء المشوار بنجاح 🏁',
                            "أحسنت! تم إكمال المشوار #{$trip->id} وإيداع صافي أرباحك ({$earning} ر.ي) في محفظتك.",
                            [
                                'type'        => 'trip_completed',
                                'status'      => 'completed',
                                'trip_id'     => (string) $trip->id,
                                'final_price' => (string) $trip->final_price,
                            ]
                        );
                    } catch (\Throwable $e) {}
                }
            });

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

            // [SECURITY FIX ISSUE-3.6]: Prevent mid-transit cancellation!
            if ($trip->status === 'in_transit') {
                throw new Exception("لا يمكن إلغاء الرحلة أثناء السير على الطريق. يرجى إكمال المشوار أو التواصل مع الدعم الفني.", 400);
            }

            // [SECURITY FIX]: Prevent IDOR - Only the passenger or the assigned captain can cancel the trip.
            $isPassenger = $trip->user_id === $user->id;
            $isAssignedCaptain = $user->captainProfile && $trip->captain_profile_id === $user->captainProfile->id;
            
            if (!$isPassenger && !$isAssignedCaptain) {
                throw new Exception("غير مصرح لك بإلغاء هذه الرحلة.", 403);
            }

            // [ESCROW RELEASE FIX ISSUE-3.2]: If passenger paid with wallet, release held balance
            if ($trip->payment_method === 'wallet' && $trip->user_id) {
                $passengerWallet = Wallet::where('user_id', $trip->user_id)->lockForUpdate()->first();
                if ($passengerWallet && ($passengerWallet->held_balance ?? 0) > 0) {
                    $heldToRelease = min((float) $passengerWallet->held_balance, (float) ($trip->estimated_price ?? 0));
                    $passengerWallet->held_balance = max(0.0, (float) $passengerWallet->held_balance - $heldToRelease);
                    $passengerWallet->save();
                }
            }

            // [FINANCIAL COMPENSATION FIX ISSUE-3.7]: Cancellation fee after arrival or > 2 minutes after acceptance
            $hasAssignedCaptain = $trip->captain_profile_id && $trip->captain && $trip->captain->user_id;
            $minutesSinceAcceptance = $trip->accepted_at ? now()->diffInMinutes($trip->accepted_at) : 0;
            $feeApplied = false;
            $cancellationFee = 0.0;

            if ($isPassenger && $hasAssignedCaptain && ($trip->status === 'arrived' || $minutesSinceAcceptance >= 2)) {
                $cancellationFee = (float) Cache::remember('setting_cancellation_fee', self::PRICING_CACHE_TTL,
                    fn() => Setting::where('key', 'cancellation_fee')->value('value') ?? 400.0);

                if ($cancellationFee > 0) {
                    $this->walletService->applyCancellationCompensation(
                        $trip->user_id,
                        $trip->captain->user_id,
                        $cancellationFee,
                        $trip->id
                    );
                    $feeApplied = true;
                }
            }

            $trip->update([
                'status' => 'cancelled',
                'cancelled_by' => $user->id,
                'cancellation_reason' => $reason,
                'cancelled_at' => now(),
            ]);

            $trip->load(['captain.user', 'passenger', 'stops']);

            // [PERFORMANCE FIX ISSUE-1.7]: Run broadcasting and notifications AFTER transaction commit
            DB::afterCommit(function () use ($trip, $user, $feeApplied, $cancellationFee) {
                try {
                    event(new \App\Events\TripStatusUpdated($trip));
                } catch (\Throwable $e) {}

                try {
                    if ($trip->captain && $trip->captain->user) {
                        if ($user->id === $trip->user_id) {
                            $capMsg = $feeApplied 
                                ? "قام الراكب بإلغاء المشوار #{$trip->id}. تم إيداع تعويض الإلغاء (" . number_format($cancellationFee) . " ر.ي) في محفظتك."
                                : "قام الراكب بإلغاء المشوار #{$trip->id}.";

                            $this->notificationService->sendToUser(
                                $trip->captain->user,
                                'تم إلغاء المشوار 🚫',
                                $capMsg,
                                [
                                    'type' => 'trip_cancelled',
                                    'status' => 'cancelled',
                                    'trip_id' => (string) $trip->id,
                                    'compensation' => (string) $cancellationFee,
                                ]
                            );
                        }
                    }

                    if ($trip->passenger) {
                        if ($user->id !== $trip->user_id) {
                            $this->notificationService->sendToUser(
                                $trip->passenger,
                                'تم إلغاء المشوار 🚫',
                                "قام الكابتن بإلغاء المشوار #{$trip->id}. يمكنك طلب كابتن آخر.",
                                [
                                    'type' => 'trip_cancelled',
                                    'status' => 'cancelled',
                                    'trip_id' => (string) $trip->id,
                                ]
                            );
                        } else if ($feeApplied) {
                            $this->notificationService->sendToUser(
                                $trip->passenger,
                                'رسوم إلغاء المشوار ⚠️',
                                "تم تطبيق رسوم إلغاء بقيمة (" . number_format($cancellationFee) . " ر.ي) لتعويض الكابتن بعد وصوله أو تحركه.",
                                [
                                    'type' => 'cancellation_fee_applied',
                                    'status' => 'cancelled',
                                    'trip_id' => (string) $trip->id,
                                    'fee' => (string) $cancellationFee,
                                ]
                            );
                        }
                    }
                } catch (\Throwable $e) {}
            });

            return $trip;
        });
    }

    /**
     * Re-dispatch / retry a trip search when passenger clicks "إعادة البحث".
     * Revives an expired or pending trip, resets 3-minute timer, and notifies nearby captains again.
     */
    public function retryTripSearch($tripId, User $user)
    {
        return DB::transaction(function () use ($tripId, $user) {
            $trip = Trip::where('id', $tripId)->lockForUpdate()->first();

            if (!$trip) {
                throw new Exception("المشوار المطلوب غير موجود.", 404);
            }

            if ($trip->user_id !== $user->id) {
                throw new Exception("غير مصرح لك بإعادة البحث لهذا المشوار.", 403);
            }

            if ($trip->status === 'completed' || $trip->status === 'in_progress' || $trip->status === 'accepted') {
                throw new Exception("لا يمكن إعادة البحث، المشوار قيد التنفيذ أو تم قبوله بالفعل.", 400);
            }

            // Revive trip to pending and reset timer
            $trip->update([
                'status'              => 'pending',
                'cancellation_reason' => null,
                'cancelled_at'        => null,
                'cancelled_by'        => null,
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);

            $trip->load(['passenger', 'stops']);

            // Re-broadcast NewTripRequested realtime WebSocket event
            try {
                event(new \App\Events\NewTripRequested($trip));
            } catch (\Exception $e) {
                Log::error("Failed to broadcast NewTripRequested on retry for trip #{$trip->id}: " . $e->getMessage());
            }

            // Re-notify captains via FCM in nearest-first order
            $this->notifyNearbyCaptains($trip);

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
            \App\Jobs\NotifyNearbyCaptainsJob::dispatch($trip);
        } catch (Exception $e) {
            Log::error("Failed to dispatch notify nearby captains job for trip #{$trip->id}: " . $e->getMessage());
        }
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $osrmService = app(\App\Services\OSRMService::class);
        $route = $osrmService->getRouteDetails($lat1, $lon1, $lat2, $lon2);

        if ($route && isset($route['distance'])) {
            return max($route['distance'], 1.0); // Use real OSRM road distance
        }

        // Fallback to Haversine straight-line distance if OSRM fails
        $straightLineDist = \App\Helpers\GeoHelper::haversineDistance($lat1, $lon1, $lat2, $lon2);

        $roadDist = $straightLineDist * 1.4;

        return max($roadDist, 1.0);
    }
}