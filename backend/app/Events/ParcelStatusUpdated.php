<?php

namespace App\Events;

use App\Models\Parcel;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ParcelStatusUpdated implements ShouldBroadcast, ShouldDispatchAfterCommit
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
     * We broadcast on trip.{id} so Flutter EchoService catches it without changes!
     */
    public function broadcastOn(): array
    {
        $channels = [
            new \Illuminate\Broadcasting\PrivateChannel('trip.' . $this->parcel->id),
        ];

        if (!empty($this->parcel->tracking_code)) {
            $channels[] = new \Illuminate\Broadcasting\PrivateChannel('trip.' . $this->parcel->tracking_code);
        }

        return $channels;
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'TripStatusUpdated'; // Use same name so Flutter catches it
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        $data = $this->parcel->toArray();
        return [
            'id' => (string) $this->parcel->id,
            'trip_id' => (string) $this->parcel->id,
            'type' => 'trip_' . $this->parcel->status,
            'event_type' => 'trip_' . $this->parcel->status,
            'status' => $this->parcel->status,
            'captain_id' => $this->parcel->captain_profile_id ? (string) $this->parcel->captain_profile_id : null,
            'captainId' => $this->parcel->captain_profile_id ? (string) $this->parcel->captain_profile_id : null,
            'captain_name' => $this->parcel->captain?->user?->name ?? 'الكابتن',
            'captain_phone' => $this->parcel->captain?->user?->phone ?? '',
            'vehicle_model' => $this->parcel->captain?->vehicle_model ?? 'دراجة نارية',
            'vehicle_plate' => $this->parcel->captain?->plate_number ?? '',
            'plate_number' => $this->parcel->captain?->plate_number ?? '',
            'captain_rating' => 5.0,
            'parcel' => $data,
        ];
    }
}
