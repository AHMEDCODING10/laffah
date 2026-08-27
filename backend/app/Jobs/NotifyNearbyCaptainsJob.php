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
    public function handle(NotificationService $notificationService): void
    {
        try {
            // Ideally filter by location, but as a start we chunk online captains
            // to avoid loading all into memory and freezing the server.
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
                                    'type' => 'trip_new',
                                    'trip_id' => (string) $this->trip->id,
                                    'pickup' => $this->trip->pickup_address,
                                    'dropoff' => $this->trip->dropoff_address,
                                    'price' => (string) $this->trip->estimated_price,
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
