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

        // 1. Expire Trips with atomic lock and Escrow release
        $expiredTrips = Trip::where('status', 'pending')
            ->where('created_at', '<', $threeMinutesAgo)
            ->get();

        foreach ($expiredTrips as $trip) {
            \Illuminate\Support\Facades\DB::transaction(function () use ($trip, $now) {
                $lockedTrip = Trip::where('id', $trip->id)->lockForUpdate()->first();
                if (!$lockedTrip || $lockedTrip->status !== 'pending') {
                    return; // Already accepted or cancelled concurrently
                }

                $lockedTrip->update([
                    'status'              => 'cancelled',
                    'cancellation_reason' => 'timeout_no_captain',
                    'cancelled_at'        => $now,
                ]);

                // [ESCROW RELEASE FIX]: If passenger paid with wallet, release held escrow balance
                if ($lockedTrip->payment_method === 'wallet' && $lockedTrip->user_id) {
                    $passengerWallet = \App\Models\Wallet::where('user_id', $lockedTrip->user_id)->lockForUpdate()->first();
                    if ($passengerWallet && ($passengerWallet->held_balance ?? 0) > 0) {
                        $heldToRelease = min((float) $passengerWallet->held_balance, (float) ($lockedTrip->estimated_price ?? 0));
                        $passengerWallet->held_balance = max(0.0, (float) $passengerWallet->held_balance - $heldToRelease);
                        $passengerWallet->save();
                    }
                }
            });

            Log::info("Trip #{$trip->id} auto-cancelled due to 3-minute timeout with escrow release.");
            
            try {
                event(new \App\Events\TripStatusUpdated($trip));
            } catch (\Exception $e) {}
        }

        // 2. Expire Parcels with atomic lock
        $expiredParcels = Parcel::where('status', 'pending')
            ->where('created_at', '<', $threeMinutesAgo)
            ->get();

        foreach ($expiredParcels as $parcel) {
            \Illuminate\Support\Facades\DB::transaction(function () use ($parcel) {
                $lockedParcel = Parcel::where('id', $parcel->id)->lockForUpdate()->first();
                if (!$lockedParcel || $lockedParcel->status !== 'pending') {
                    return; // Already accepted or cancelled concurrently
                }

                $lockedParcel->update([
                    'status' => 'cancelled',
                    'notes'  => 'انتهت مهلة انتظار الكابتن (3 دقائق)',
                ]);
            });

            Log::info("Parcel #{$parcel->id} auto-cancelled due to 3-minute timeout.");
            
            try {
                event(new \App\Events\ParcelStatusUpdated($parcel));
            } catch (\Exception $e) {}
        }

        $this->info("Expired " . $expiredTrips->count() . " trips and " . $expiredParcels->count() . " parcels.");
    }
}
