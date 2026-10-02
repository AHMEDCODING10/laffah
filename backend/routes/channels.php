<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\Trip;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('captain-location.{captainId}', function ($user, $captainId) {
    // Only the specific captain, an admin, or a passenger with an active trip with this captain can listen
    $isSameCaptain = (int) $user->captainProfile?->id === (int) $captainId;
    $isAdmin = $user->hasRole('admin');
    $hasActiveTrip = \App\Models\Trip::where('user_id', $user->id)
        ->where('captain_profile_id', $captainId)
        ->whereIn('status', ['accepted', 'arrived', 'in_transit'])
        ->exists();

    return $isSameCaptain || $isAdmin || $hasActiveTrip;
});

Broadcast::channel('captain.{captainId}', function ($user, $captainId) {
    // Only the specific captain can listen to their private targeted trip requests
    return (int) $user->captainProfile?->id === (int) $captainId;
});

Broadcast::channel('captains-locations', function ($user) {
    // All authenticated users / admins can listen to general map
    return true;
});

Broadcast::channel('trips.available', function ($user) {
    // Only captains can listen to available trips
    return $user->hasRole('captain');
});

Broadcast::channel('trip.{tripId}', function ($user, $tripId) {
    $trip = Trip::find($tripId);
    if (!$trip) return false;
    
    // Only the passenger of this trip or the assigned captain can listen
    return (int) $user->id === (int) $trip->user_id || 
           (int) $user->captainProfile?->id === (int) $trip->captain_profile_id;
});
