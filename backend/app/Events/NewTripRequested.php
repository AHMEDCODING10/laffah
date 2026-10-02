<?php

namespace App\Events;

use App\Models\Trip;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewTripRequested implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $trip;
    public $targetCaptainId;

    /**
     * Create a new event instance.
     */
    public function __construct(Trip $trip, $targetCaptainId = null)
    {
        $this->trip = $trip;
        $this->targetCaptainId = $targetCaptainId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        if ($this->targetCaptainId) {
            // Targeted dispatch (Smart Queue)
            return [
                new PrivateChannel('captain.' . $this->targetCaptainId),
            ];
        }

        // Broadcast to public channel so online captains can listen seamlessly (Legacy)
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
            'id' => (string) $this->trip->id,
            'trip_id' => (string) $this->trip->id,
            'type' => 'trip_new',
            'event_type' => 'trip_new',
            'passenger_name' => $this->trip->passenger?->name ?? 'الراكب',
            'passenger_phone' => $this->trip->passenger?->phone ?? '',
            'passenger_rating' => (float) ($this->trip->passenger?->rating ?? 5.0),
            'pickup_address' => $this->trip->pickup_address,
            'dropoff_address' => $this->trip->dropoff_address,
            'fare' => (float) $this->trip->estimated_price,
            'price' => (string) $this->trip->estimated_price,
            'distance' => $this->trip->distance_km ? ($this->trip->distance_km . ' كم') : '2.5 كم',
            'duration' => '5 د',
            'timeTag' => 'الآن',
            'payment_method' => $this->trip->payment_method,
            'trip' => (new \App\Http\Resources\TripResource($this->trip))->resolve(),
        ];
    }
}
