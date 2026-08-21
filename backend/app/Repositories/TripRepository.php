<?php

namespace App\Repositories;

use App\Models\Trip;
use Illuminate\Database\Eloquent\Collection;

class TripRepository implements TripRepositoryInterface
{
    public function getTripsByCaptain(int $captainProfileId): Collection
    {
        return Trip::where('captain_profile_id', $captainProfileId)
            ->with(['stops', 'passenger'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getTripsByUser(int $userId): Collection
    {
        return Trip::where('user_id', $userId)
            ->with(['stops', 'captain.user'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getNearbyPendingTrips(int $limit = 20): Collection
    {
        return Trip::where('status', 'pending')
            ->whereNull('captain_profile_id')
            ->where('created_at', '>=', now()->subMinutes(3))
            ->with(['stops', 'passenger'])
            ->orderBy('created_at', 'desc')
            ->take($limit)
            ->get();
    }
}
