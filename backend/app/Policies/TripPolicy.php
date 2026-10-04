<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Trip;
use Illuminate\Auth\Access\HandlesAuthorization;

class TripPolicy
{
    use HandlesAuthorization;

    /**
     * Intercept all checks to allow administrators full access.
     */
    public function before(User $user, string $ability)
    {
        if ($user->hasRole('admin') || !empty($user->is_admin)) {
            return true;
        }
    }

    /**
     * Determine whether the user can view the trip.
     */
    public function view(User $user, Trip $trip): bool
    {
        // Passenger who requested the trip
        if ($trip->user_id === $user->id) {
            return true;
        }

        // Assigned Captain
        if ($user->captainProfile && $trip->captain_profile_id === $user->captainProfile->id) {
            return true;
        }

        // Any online active captain can view a pending trip if it's currently unassigned
        if ($trip->status === 'pending' && is_null($trip->captain_profile_id) && $user->hasRole('captain')) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can accept the trip.
     */
    public function accept(User $user, Trip $trip): bool
    {
        if (!$user->hasRole('captain') || !$user->captainProfile) {
            return false;
        }

        return $trip->status === 'pending' && is_null($trip->captain_profile_id);
    }

    /**
     * Determine whether the user can update the status of the trip.
     */
    public function updateStatus(User $user, Trip $trip): bool
    {
        if (!$user->captainProfile) {
            return false;
        }

        return (int) $trip->captain_profile_id === (int) $user->captainProfile->id;
    }

    /**
     * Determine whether the user can cancel the trip.
     */
    public function cancel(User $user, Trip $trip): bool
    {
        // Trip cannot be cancelled mid-transit
        if ($trip->status === 'in_transit' || $trip->status === 'completed' || $trip->status === 'cancelled') {
            return false;
        }

        if ($trip->user_id === $user->id) {
            return true;
        }

        if ($user->captainProfile && $trip->captain_profile_id === $user->captainProfile->id) {
            return true;
        }

        return false;
    }

    /**
     * Soft archive/delete: Strictly forbidden for regular users and captains.
     */
    public function delete(User $user, Trip $trip): bool
    {
        // Only high-privileged administrators can soft-archive a financial trip record
        return false;
    }
}
