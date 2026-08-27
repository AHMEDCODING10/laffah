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