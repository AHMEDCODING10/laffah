<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\CaptainProfile;
use App\Models\CaptainLocation;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class AutoOfflineInactiveCaptains extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'captains:auto-offline {--minutes=5 : Inactivity threshold in minutes}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Automatically switch captains to offline status if inactive for more than 5 minutes';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $minutes = (int) $this->option('minutes');
        $threshold = Carbon::now()->subMinutes($minutes);

        // Find all online captains whose location was not updated recently
        $inactiveCaptains = CaptainProfile::where('is_online', true)
            ->whereHas('location', function ($query) use ($threshold) {
                $query->where('updated_at', '<', $threshold);
            })
            ->orWhere(function ($query) use ($threshold) {
                $query->where('is_online', true)
                    ->where('updated_at', '<', $threshold)
                    ->whereDoesntHave('location');
            })
            ->get();

        $count = $inactiveCaptains->count();

        if ($count === 0) {
            $this->info('No inactive captains found.');
            return 0;
        }

        foreach ($inactiveCaptains as $captain) {
            $captain->update(['is_online' => false]);

            CaptainLocation::where('captain_profile_id', $captain->id)
                ->update(['is_online' => false]);

            Log::info("Captain #{$captain->id} (User #{$captain->user_id}) automatically set to offline due to {$minutes}+ minutes of inactivity.");
        }

        $this->info("Successfully switched {$count} inactive captain(s) to offline.");
        return 0;
    }
}