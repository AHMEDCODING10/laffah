<?php

namespace App\Livewire\Admin;

use App\Models\CaptainLocation;
use App\Models\CaptainProfile;
use App\Models\Trip;
use Livewire\Component;
use Livewire\Attributes\On;

class LiveMap extends Component
{
    public function render()
    {
        return view('livewire.admin.live-map');
    }

    #[On('getMapData')]
    public function getMapData()
    {
        // Get captains with real-time location from CaptainLocation table
        // (updated by the mobile app via /api/captain/update-location)
        $captains = CaptainLocation::with('profile.user')
                        ->where('updated_at', '>=', now()->subMinutes(30))
                        ->get()
                        ->map(function ($loc) {
                            return [
                                'id'   => $loc->captain_profile_id,
                                'name' => optional(optional($loc->profile)->user)->name ?? 'كابتن',
                                'lat'  => (float) $loc->latitude,
                                'lng'  => (float) $loc->longitude,
                            ];
                        })
                        ->values();

        // Active trips
        $trips = Trip::with(['passenger', 'captain.user'])
                    ->whereIn('status', ['accepted', 'started', 'on_the_way', 'arrived', 'pending'])
                    ->get()
                    ->map(function ($trip) {
                        return [
                            'id'        => $trip->id,
                            'passenger' => optional($trip->passenger)->name ?? 'غير معروف',
                            'captain'   => optional(optional($trip->captain)->user)->name ?? 'غير معروف',
                            'pickup'    => $trip->pickup_address ?? '',
                            'dropoff'   => $trip->dropoff_address ?? '',
                            'status'    => $trip->status,
                        ];
                    })
                    ->values();

        // Stats counts (regardless of location data)
        $onlineCount  = CaptainProfile::where('is_online', true)->count();
        $activeTrips  = Trip::whereIn('status', ['accepted', 'started', 'on_the_way', 'arrived'])->count();

        $this->dispatch('mapDataRefreshed',
            captains:    $captains->toArray(),
            trips:       $trips->toArray(),
            onlineCount: $onlineCount,
            activeTrips: $activeTrips,
        );
    }
}