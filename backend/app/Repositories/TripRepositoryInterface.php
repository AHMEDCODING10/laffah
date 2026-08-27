<?php

namespace App\Repositories;

use App\Models\Trip;
use Illuminate\Database\Eloquent\Collection;

interface TripRepositoryInterface
{
    public function getTripsByCaptain(int $captainProfileId): Collection;
    public function getTripsByUser(int $userId): Collection;
    public function getNearbyPendingTrips(int $limit = 20): Collection;
}
