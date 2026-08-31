<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Schedule auto-offline for inactive captains every minute
Schedule::command('captains:auto-offline --minutes=5')
    ->everyMinute()
    ->runInBackground()
    ->withoutOverlapping();

// Dispatch scheduled trips that are due within 15 minutes
Schedule::command('trips:dispatch-scheduled')
    ->everyMinute()
    ->runInBackground()
    ->withoutOverlapping();

// Expire pending requests (trips/parcels) that are older than 3 minutes
Schedule::command('requests:expire-pending')
    ->everyMinute()
    ->runInBackground()
    ->withoutOverlapping();