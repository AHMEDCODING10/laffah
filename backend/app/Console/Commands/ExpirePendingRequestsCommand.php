<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Trip;
use App\Models\Parcel;
use Illuminate\Support\Facades\Log;

class ExpirePendingRequestsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'requests:expire-pending';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Expire pending trips and parcels that have been waiting for more than 3 minutes without a captain accepting them.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info("Starting expiration of pending requests...");
        $now = now();
        $threeMinutesAgo = $now->copy()->subMinutes(3);

        // 1. Expire Trips
        $expiredTrips = Trip::where('status', 'pending')
            ->where('created_at', '<', $threeMinutesAgo)
            ->get();

        foreach ($expiredTrips as $trip) {
            $trip->update([
                'status' => 'cancelled',
                'cancellation_reason' => 'timeout_no_captain',
                'cancelled_at' => $now,
            ]);
            Log::info("Trip #{$trip->id} auto-cancelled due to 3-minute timeout.");
            
            try {
                event(new \App\Events\TripStatusUpdated($trip));
            } catch (\Exception $e) {}
        }

        // 2. Expire Parcels
        $expiredParcels = Parcel::where('status', 'pending')
            ->where('created_at', '<', $threeMinutesAgo)
            ->get();

        foreach ($expiredParcels as $parcel) {
            $parcel->update([
                'status' => 'cancelled',
            ]);
            Log::info("Parcel #{$parcel->id} auto-cancelled due to 3-minute timeout.");
            
            try {
                event(new \App\Events\ParcelStatusUpdated($parcel));
            } catch (\Exception $e) {}
        }

        $this->info("Expired " . $expiredTrips->count() . " trips and " . $expiredParcels->count() . " parcels.");
    }
}
