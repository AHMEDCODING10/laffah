<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Trip;
use Carbon\Carbon;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Log;

class DispatchScheduledTripsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'trips:dispatch-scheduled';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Dispatch scheduled trips that are coming up within the next 15 minutes';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // Find trips that are scheduled for the next 15 minutes
        $now = Carbon::now();
        $targetTime = Carbon::now()->addMinutes(15);

        $trips = Trip::where('is_scheduled', true)
            ->where('status', 'scheduled')
            ->whereNotNull('scheduled_time')
            ->whereBetween('scheduled_time', [$now, $targetTime])
            ->get();

        if ($trips->isEmpty()) {
            $this->info('No scheduled trips to dispatch at this time.');
            return;
        }

        foreach ($trips as $trip) {
            $this->info("Dispatching scheduled trip #{$trip->id}");
            
            // Mark it as pending so it becomes active
            $trip->update(['status' => 'pending']);

            try {
                // Find captains within 10 km
                $nearbyCaptainIds = Redis::georadius(
                    'captains_location', 
                    $trip->pickup_longitude, 
                    $trip->pickup_latitude, 
                    15, 
                    'km', 
                    ['WITHDIST', 'ASC']
                );

                if (!empty($nearbyCaptainIds)) {
                    $captainIdsOnly = array_map(function($item) {
                        return $item[0];
                    }, $nearbyCaptainIds);

                    // Push to Redis List (Queue)
                    Redis::rpush("trip_queue:{$trip->id}", ...$captainIdsOnly);
                    Redis::expire("trip_queue:{$trip->id}", 900); // 15 mins expiry

                    // Start the sequential dispatch job
                    \App\Jobs\DispatchTripToNextCaptainJob::dispatch($trip->id);
                } else {
                    \App\Jobs\NotifyNearbyCaptainsJob::dispatch($trip);
                }
            } catch (\Exception $e) {
                Log::error("Failed to geo-dispatch scheduled trip {$trip->id}: " . $e->getMessage());
                \App\Jobs\NotifyNearbyCaptainsJob::dispatch($trip);
            }
        }
        
        $this->info("Successfully dispatched {$trips->count()} scheduled trips.");
    }
}
