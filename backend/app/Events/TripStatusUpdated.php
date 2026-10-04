<?php

namespace App\Events;

use App\Models\Trip;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class TripStatusUpdated implements ShouldBroadcast, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $trip;

    /**
     * Create a new event instance.
     */
    public function __construct(Trip $trip)
    {
        $this->trip = $trip;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new \Illuminate\Broadcasting\PrivateChannel('trip.' . $this->trip->id),
            new \Illuminate\Broadcasting\PrivateChannel('trips.available'),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'TripStatusUpdated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'id' => (string) $this->trip->id,
            'trip_id' => (string) $this->trip->id,
            'type' => 'trip_' . $this->trip->status,
            'event_type' => 'trip_' . $this->trip->status,
            'status' => $this->trip->status,
            'is_available' => $this->trip->status === 'pending' && is_null($this->trip->captain_profile_id),
            'captain_id' => $this->trip->captain_profile_id ? (string) $this->trip->captain_profile_id : null,
            'captainId' => $this->trip->captain_profile_id ? (string) $this->trip->captain_profile_id : null,
            'captain_name' => $this->trip->captain?->user?->name ?? 'الكابتن',
            'captain_phone' => $this->trip->captain?->user?->phone ?? '',
            'vehicle_model' => $this->trip->captain?->vehicle_model ?? 'دراجة نارية',
            'vehicle_plate' => $this->trip->captain?->plate_number ?? '',
            'plate_number' => $this->trip->captain?->plate_number ?? '',
            'rating' => (float) ($this->trip->rating_by_user ?? 5.0),
            'payment_method' => $this->trip->payment_method,
            'distance' => number_format((float) ($this->trip->distance_km ?? 1.0), 1) . ' كم',
            'duration' => max(1, (int) round(((float) ($this->trip->distance_km ?? 1.0)) * 2.5)) . ' دقيقة',
            'duration_minutes' => max(1, (int) round(((float) ($this->trip->distance_km ?? 1.0)) * 2.5)),
            'price' => (float) ($this->trip->final_price ?? $this->trip->estimated_price ?? 0),
            'fare' => (float) ($this->trip->final_price ?? $this->trip->estimated_price ?? 0),
            'trip' => (new \App\Http\Resources\TripResource($this->trip))->resolve(),
        ];
    }
}
