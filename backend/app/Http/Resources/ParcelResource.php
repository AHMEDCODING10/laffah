<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ParcelResource extends JsonResource
{
    public function toArray($request)
    {
        $statusAliases = [
            'pending'           => 'pending',
            'accepted'          => 'accepted',
            'arrived_at_pickup' => 'arrived',
            'picked_up'         => 'in_transit',
            'in_transit'        => 'in_transit',
            'delivered'         => 'completed',
            'cancelled'         => 'cancelled',
        ];

        return [
            'id'                  => $this->id,
            'type'                => 'parcel',
            'tracking_code'       => $this->tracking_code,
            'is_multi_stop'       => false,
            'pickup_address'      => $this->pickup_address,
            'pickup_latitude'     => $this->pickup_latitude,
            'pickup_longitude'    => $this->pickup_longitude,
            'dropoff_address'     => $this->dropoff_address,
            'dropoff_latitude'    => $this->dropoff_latitude,
            'dropoff_longitude'   => $this->dropoff_longitude,
            'status'              => $statusAliases[$this->status] ?? $this->status,
            'original_status'     => $this->status,
            'price'               => $this->price,
            'final_price'         => $this->price,
            'distance_km'         => 0.0,
            'stops'               => [],
            'created_at'          => clone $this->created_at,
            'accepted_at'         => clone ($this->accepted_at ?? $this->created_at),
            
            // Map sender as "passenger" for the app UI
            'passenger'           => [
                'id'     => $this->user_id,
                'name'   => $this->sender_name ?? ($this->user->name ?? ''),
                'phone'  => $this->sender_phone ?? ($this->user->phone ?? ''),
                'avatar' => $this->user->avatar ?? null,
                'rating' => 5.0,
            ],
            
            'parcel_details'      => [
                'type'           => $this->parcel_type,
                'size'           => $this->size,
                'receiver_name'  => $this->receiver_name,
                'receiver_phone' => $this->receiver_phone,
                'notes'          => $this->notes,
            ],
            
            'captain'             => $this->captainProfile ? [
                'id'            => $this->captainProfile->id,
                'name'          => $this->captainProfile->user->name ?? '',
                'phone'         => $this->captainProfile->user->phone ?? '',
                'vehicle_model' => $this->captainProfile->vehicle_model,
                'plate_number'  => $this->captainProfile->plate_number,
                'rating'        => $this->captainProfile->rating ?? 5.0,
                'lat'           => $this->captainProfile->latitude,
                'lng'           => $this->captainProfile->longitude,
            ] : null,
        ];
    }
}
