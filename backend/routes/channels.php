<?php

use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Cache;
use App\Models\Trip;
use App\Models\Parcel;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

/**
 * Real-time GPS Location Channel for Captains.
 * Accessible by:
 * 1. The Captain themselves.
 * 2. System Administrators.
 * 3. Passengers with an active Ride (Trip).
 * 4. Senders/Receivers with an active Parcel delivery.
 */
Broadcast::channel('captain-location.{captainId}', function ($user, $captainId) {
    $captainId = (int) $captainId;
    $userId = (int) $user->id;

    // 1. If user is the captain themself
    if ((int) $user->captainProfile?->id === $captainId) {
        return true;
    }

    // 2. Administrators
    if ($user->hasRole('admin') || !empty($user->is_admin)) {
        return true;
    }

    // 3. Fast cached authorization check for active trip or active parcel delivery
    $cacheKey = "auth_ws_cap_{$captainId}_usr_{$userId}";
    return Cache::remember($cacheKey, 20, function () use ($userId, $captainId) {
        // Check active ride
        $hasActiveTrip = Trip::where('user_id', $userId)
            ->where('captain_profile_id', $captainId)
            ->whereIn('status', ['accepted', 'arrived', 'in_transit'])
            ->exists();

        if ($hasActiveTrip) {
            return true;
        }

        // Check active parcel delivery (Fix for P0-07)
        return Parcel::where('user_id', $userId)
            ->where('captain_profile_id', $captainId)
            ->whereIn('status', ['accepted', 'arrived_at_pickup', 'picked_up', 'in_transit'])
            ->exists();
    });
});

Broadcast::channel('captain.{captainId}', function ($user, $captainId) {
    return (int) $user->captainProfile?->id === (int) $captainId;
});

Broadcast::channel('captains-locations', function ($user) {
    return $user !== null;
});

Broadcast::channel('trips.available', function ($user) {
    return $user->hasRole('captain') || !empty($user->captainProfile);
});

Broadcast::channel('trip.{tripId}', function ($user, $tripId) {
    $trip = Trip::find($tripId);
    if (!$trip) {
        // Fallback check if it's a parcel (by numeric id or string tracking_code)
        $parcel = is_numeric($tripId)
            ? Parcel::find($tripId)
            : Parcel::where('tracking_code', $tripId)->first();

        if (!$parcel) return false;
        return (int) $user->id === (int) $parcel->user_id ||
               (int) $user->captainProfile?->id === (int) $parcel->captain_profile_id;
    }

    return (int) $user->id === (int) $trip->user_id ||
           (int) $user->captainProfile?->id === (int) $trip->captain_profile_id;
});
