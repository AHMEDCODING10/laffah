<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TripResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array<string, mixed>
     */
    public function toArray($request)
    {
        $stopsCount = $this->stops ? $this->stops->count() : 0;
        $captainUser = $this->captain?->user;
        $dist = (float) ($this->distance_km ?? 1.0);
        $estDuration = max(1, (int) round($dist * 2.5)); // in minutes
        $price = (float) ($this->final_price ?? $this->estimated_price ?? 0);
        
        // Compute nearby active captains for pickup location sorted nearest-first
        $nearbyCaptains = 0;
        $captainEtaMinutes = 4;
        if ($this->pickup_latitude && $this->pickup_longitude) {
            $lat = (float) $this->pickup_latitude;
            $lng = (float) $this->pickup_longitude;
            $radiusKm = 4.5; // Max economic search radius for Sanaa pickup
            $latDelta = $radiusKm / 111.0;
            $lngDelta = $radiusKm / (111.0 * max(0.1, cos(deg2rad($lat))));
            $haversine = "(6371 * acos(cos(radians($lat)) * cos(radians(captain_locations.latitude)) * cos(radians(captain_locations.longitude) - radians($lng)) + sin(radians($lat)) * sin(radians(captain_locations.latitude))))";

            $captains = \Illuminate\Support\Facades\DB::table('captain_locations')
                ->join('captain_profiles', 'captain_locations.captain_profile_id', '=', 'captain_profiles.id')
                ->where('captain_profiles.is_online', true)
                ->whereBetween('captain_locations.latitude', [$lat - $latDelta, $lat + $latDelta])
                ->whereBetween('captain_locations.longitude', [$lng - $lngDelta, $lng + $lngDelta])
                ->where('captain_locations.last_updated_at', '>=', now()->subMinutes(15))
                ->whereRaw("$haversine <= ?", [$radiusKm])
                ->select(\Illuminate\Support\Facades\DB::raw("$haversine as distance_km"))
                ->orderBy('distance_km', 'asc')
                ->get();

            if ($captains->isEmpty()) {
                $captains = \Illuminate\Support\Facades\DB::table('captain_locations')
                    ->join('captain_profiles', 'captain_locations.captain_profile_id', '=', 'captain_profiles.id')
                    ->where('captain_profiles.is_online', true)
                    ->whereBetween('captain_locations.latitude', [$lat - $latDelta, $lat + $latDelta])
                    ->whereBetween('captain_locations.longitude', [$lng - $lngDelta, $lng + $lngDelta])
                    ->whereRaw("$haversine <= ?", [$radiusKm])
                    ->select(\Illuminate\Support\Facades\DB::raw("$haversine as distance_km"))
                    ->orderBy('distance_km', 'asc')
                    ->get();
            }

            $nearbyCaptains = $captains->count();

            if ($nearbyCaptains === 0) {
                $onlinePool = \App\Models\CaptainProfile::where('is_online', true)->count();
                if ($onlinePool > 0) {
                    $nearbyCaptains = min($onlinePool, 5);
                }
            } else {
                $nearestDist = $captains->first()->distance_km;
                $captainEtaMinutes = max(2, (int) round(($nearestDist / 20.0) * 60) + 1);
            }
        }
        
        return [
            'id' => (string) $this->id,
            'status' => $this->status,
            'type' => $this->type ?? 'ride',
            'payment_method' => $this->payment_method ?? 'cash',
            'nearby_captains' => $nearbyCaptains,
            'nearbyCaptains' => $nearbyCaptains,
            'nearbyCaptainsCount' => $nearbyCaptains,
            'captain_eta_minutes' => $captainEtaMinutes,
            'captainEtaMinutes' => $captainEtaMinutes,
            'isParcel' => ($this->type === 'delivery'),
            'title' => $this->type === 'delivery' 
                ? 'طلب توصيل طرد 📦' 
                : ($stopsCount > 0 ? 'مشوار متعدد المحطات والتوقفات ⚡' : 'طلب مشوار جديد 🛵'),
            'description' => $this->pickup_address . ' ← ' . $this->dropoff_address,
            
            // Pricing & Metrics
            'price' => $price,
            'estimated_price' => (float) ($this->estimated_price ?? 0),
            'final_price' => $this->final_price ? (float) $this->final_price : null,
            'grossFare' => $price,
            'distance_km' => $dist,
            'distance' => number_format($dist, 1) . ' كم',
            'eta' => "~{$estDuration} دقيقة",
            'duration' => "{$estDuration} د",
            'timeTag' => $this->created_at ? $this->created_at->diffForHumans() : 'الآن',
            'currency' => 'YER',
            
            // Pickup & Dropoff
            'pickup' => $this->pickup_address,
            'pickup_address' => $this->pickup_address,
            'pickup_location' => $this->pickup_address,
            'pickup_latitude' => (float) $this->pickup_latitude,
            'pickup_longitude' => (float) $this->pickup_longitude,
            
            'dropoff' => $this->dropoff_address,
            'dropoff_address' => $this->dropoff_address,
            'dropoff_location' => $this->dropoff_address,
            'dropoff_latitude' => (float) $this->dropoff_latitude,
            'dropoff_longitude' => (float) $this->dropoff_longitude,
            
            // Passenger Details
            'passengerName' => $this->passenger?->name ?? 'عميل',
            'passengerPhone' => $this->passenger?->phone ?? '',
            'passengerRating' => (float) ($this->passenger?->passengerTrips()->whereNotNull('rating_by_captain')->avg('rating_by_captain') ?? 5.0),
            'passenger' => [
                'id' => $this->passenger?->id,
                'name' => $this->passenger?->name ?? 'عميل',
                'phone' => $this->passenger?->phone ?? '',
            ],
            
            // Captain Details
            'captain_name' => $captainUser?->name,
            'captain_phone' => $captainUser?->phone,
            'captain' => $this->captain ? [
                'id' => $this->captain->id,
                'name' => $captainUser?->name,
                'phone' => $captainUser?->phone,
                'vehicle_model' => $this->captain->vehicle_model,
                'plate_number' => $this->captain->plate_number,
                'vehicle_color' => $this->captain->vehicle_color,
                'user' => $captainUser ? [
                    'id' => $captainUser->id,
                    'name' => $captainUser->name,
                    'phone' => $captainUser->phone,
                ] : null,
            ] : null,
            'rating' => (float) ($this->rating_by_user ?? 5.0),
            'vehicle_model' => $this->captain?->vehicle_model ?? 'دراجة نارية',
            'vehicle_plate' => $this->captain?->plate_number ?? '',
            'vehicle_color' => $this->captain?->vehicle_color ?? '',
            
            // Stops & Timestamps
            'stops' => $this->stops ? $this->stops->map(function($stop, $index) {
                return [
                    'order' => $stop->stop_order ?? ($index + 1),
                    'address' => $stop->address,
                    'latitude' => (float) $stop->latitude,
                    'longitude' => (float) $stop->longitude,
                ];
            })->toArray() : [],
            'created_at' => $this->created_at ? ($this->created_at instanceof \Carbon\Carbon ? $this->created_at->toIso8601String() : (string) $this->created_at) : null,
            'accepted_at' => $this->accepted_at ? ($this->accepted_at instanceof \Carbon\Carbon ? $this->accepted_at->toIso8601String() : (string) $this->accepted_at) : null,
            'started_at' => $this->started_at ? ($this->started_at instanceof \Carbon\Carbon ? $this->started_at->toIso8601String() : (string) $this->started_at) : null,
            'completed_at' => $this->completed_at ? ($this->completed_at instanceof \Carbon\Carbon ? $this->completed_at->toIso8601String() : (string) $this->completed_at) : null,
            'cancelled_at' => $this->cancelled_at ? ($this->cancelled_at instanceof \Carbon\Carbon ? $this->cancelled_at->toIso8601String() : (string) $this->cancelled_at) : null,
            'updated_at' => $this->updated_at ? ($this->updated_at instanceof \Carbon\Carbon ? $this->updated_at->toIso8601String() : (string) $this->updated_at) : null,
            'cancelled_by' => $this->cancelled_by,
            'cancellation_reason' => $this->cancellation_reason,
        ];
    }
}