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
use Illuminate\Support\Facades\Redis;

class DispatchTripToNextCaptainJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $tripId;

    /**
     * Create a new job instance.
     */
    public function __construct(int $tripId)
    {
        $this->tripId = $tripId;
    }

    /**
     * Execute the job.
     */
    public function handle(NotificationService $notificationService): void
    {
        try {
            $trip = Trip::find($this->tripId);
            if (!$trip || $trip->status !== 'pending') {
                return; // Trip is already accepted or cancelled
            }

            // Pop the next captain from the queue
            $captainId = null;
            try {
                $captainId = Redis::lpop("trip_queue:{$this->tripId}");
            } catch (\Exception $e) {
                // If Redis fails, gracefully exit for now. Could fallback to old chunking if needed.
                Log::error("Redis lpop failed for trip queue: " . $e->getMessage());
                return;
            }

            if (!$captainId) {
                // No more captains in the queue, fallback to global broadcast if still pending
                Log::info("No more captains in queue for trip #{$this->tripId}, falling back to global broadcast");
                // Clear the offer lock
                Redis::del("trip_offer:{$this->tripId}");
                $tripService = app(\App\Services\TripService::class);
                $tripService->notifyNearbyCaptains($trip);
                return;
            }

            $captain = CaptainProfile::with('user')->find($captainId);

            if ($captain && $captain->user && $captain->is_online) {
                // Record the current offered captain in Redis so polling endpoint knows who is allowed to see it
                Redis::setex("trip_offer:{$this->tripId}", 15, $captain->id);

                // Send targeted push notification
                $notificationService->sendToUser(
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
                
                // Targeted Pusher event (NewTripRequested needs to handle targeted ID if implemented, or we rely on FCM)
                try {
                    event(new \App\Events\NewTripRequested($trip, clone $captain));
                } catch (\Exception $e) {}
            }

            // Dispatch again after 10 seconds to try the next captain if this one doesn't accept
            self::dispatch($this->tripId)->delay(now()->addSeconds(10));
            
        } catch (\Exception $e) {
            Log::error("Failed to dispatch trip #{$this->tripId} to next captain: " . $e->getMessage());
        }
    }
}
