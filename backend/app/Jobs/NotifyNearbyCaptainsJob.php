<?php

namespace App\Jobs;

use App\Models\Trip;
use App\Models\CaptainProfile;
use App\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class NotifyNearbyCaptainsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $trip;

    /**
     * Create a new job instance.
     */
    public function __construct(Trip $trip)
    {
        $this->trip = $trip;
    }

    /**
     * Execute the job.
     */
    public function handle(NotificationService $notificationService, \App\Services\TripService $tripService): void
    {
        try {
            $lat = (float) ($this->trip->pickup_latitude ?? 0);
            $lng = (float) ($this->trip->pickup_longitude ?? 0);

            if ($lat > 0 && $lng > 0) {
                // Fetch captains sorted Nearest-First with 15-minute freshness (up to 4.5km max economic limit)
                $nearbyCaptains = $tripService->getNearbyCaptainsSorted($lat, $lng, 4.5, 15);

                if ($nearbyCaptains->isNotEmpty()) {
                    $captainProfileIds = $nearbyCaptains->pluck('captain_profile_id')->toArray();

                    $captainProfiles = CaptainProfile::whereIn('id', $captainProfileIds)
                        ->whereNotNull('user_id')
                        ->with('user')
                        ->get()
                        ->keyBy('id');

                    // Notify captains in nearest-first order
                    foreach ($nearbyCaptains as $capData) {
                        $profile = $captainProfiles->get($capData->captain_profile_id);
                        if ($profile && $profile->user) {
                            $distKm = round((float) $capData->distance_km, 2);
                            $distText = $distKm < 0.1
                                ? 'على بعد أمتار قليلة منك 📍'
                                : ($distKm < 1.0
                                    ? "يبعد عنك " . (int)($distKm * 1000) . " متر 📍"
                                    : "يبعد عنك {$distKm} كم 📍");

                            $notificationService->sendToUser(
                                $profile->user,
                                'طلب مشوار جديد! 🛵',
                                "مشوار من {$this->trip->pickup_address} إلى {$this->trip->dropoff_address} ({$distText}) بقيمة " . number_format($this->trip->estimated_price) . " ريال",
                                [
                                    'type'                  => 'trip_new',
                                    'trip_id'               => (string) $this->trip->id,
                                    'pickup'                => $this->trip->pickup_address,
                                    'dropoff'               => $this->trip->dropoff_address,
                                    'price'                 => (string) $this->trip->estimated_price,
                                    'distance_to_pickup_km' => (string) $distKm,
                                ]
                            );
                        }
                    }
                    return;
                }
            }

            // Fallback: Notify online captains chunked if coordinates unavailable or zero captains in range
            CaptainProfile::where('is_online', true)
                ->whereNotNull('user_id')
                ->with('user')
                ->chunk(100, function ($captains) use ($notificationService) {
                    foreach ($captains as $captain) {
                        if ($captain->user) {
                            $notificationService->sendToUser(
                                $captain->user,
                                'طلب مشوار جديد! 🛵',
                                "مشوار من {$this->trip->pickup_address} إلى {$this->trip->dropoff_address} بقيمة " . number_format($this->trip->estimated_price) . " ريال",
                                [
                                    'type'    => 'trip_new',
                                    'trip_id' => (string) $this->trip->id,
                                    'pickup'  => $this->trip->pickup_address,
                                    'dropoff' => $this->trip->dropoff_address,
                                    'price'   => (string) $this->trip->estimated_price,
                                ]
                            );
                        }
                    }
                });
        } catch (\Exception $e) {
            Log::error("Failed to notify nearby captains for trip #{$this->trip->id} in Job: " . $e->getMessage());
        }
    }
}
