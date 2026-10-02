<?php

namespace App\Events;

use App\Models\Parcel;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewParcelRequested implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $parcel;

    /**
     * Create a new event instance.
     */
    public function __construct(Parcel $parcel)
    {
        $this->parcel = $parcel;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new \Illuminate\Broadcasting\PrivateChannel('trips.available'),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'NewTripRequested';
    }

    /**
     * Get the data to broadcast.
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'id' => (string) $this->parcel->id,
            'trip_id' => (string) $this->parcel->id,
            'type' => 'trip_new',
            'event_type' => 'trip_new',
            'passenger_name' => $this->parcel->sender_name ?? 'المرسل',
            'passenger_phone' => $this->parcel->sender_phone ?? '',
            'passenger_rating' => 5.0,
            'pickup_address' => $this->parcel->pickup_address,
            'dropoff_address' => $this->parcel->dropoff_address,
            'fare' => (float) $this->parcel->price,
            'price' => (string) $this->parcel->price,
            'distance' => ($this->parcel->distance_km ?? 2.5) . ' كم',
            'duration' => '6 د',
            'timeTag' => 'الآن',
            'is_parcel' => true,
            'isParcel' => true,
            'parcel_type' => $this->parcel->parcel_type ?? 'طرد',
            'size' => $this->parcel->size ?? 'متوسط',
            'pickupLat' => (float) $this->parcel->pickup_latitude,
            'pickupLng' => (float) $this->parcel->pickup_longitude,
            'dropoffLat' => (float) $this->parcel->dropoff_latitude,
            'dropoffLng' => (float) $this->parcel->dropoff_longitude,
        ];
    }
}
