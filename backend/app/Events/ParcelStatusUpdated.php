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
        return [
            new Channel('trip.' . $this->parcel->id),
        ];
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
            'status' => $this->parcel->status,
            'captain_name' => $this->parcel->captain?->user?->name ?? 'الكابتن',
            'captain_phone' => $this->parcel->captain?->user?->phone ?? '',
            'vehicle_model' => $this->parcel->captain?->vehicle_model ?? 'دراجة نارية',
            'plate_number' => $this->parcel->captain?->plate_number ?? '',
            'captain_rating' => 5.0,
            'parcel' => $data,
        ];
    }
}
