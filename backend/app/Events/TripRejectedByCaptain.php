<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class TripRejectedByCaptain implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $tripId;
    public $captainProfileId;

    /**
     * Create a new event instance.
     */
    public function __construct($tripId, $captainProfileId)
    {
        $this->tripId = (string) $tripId;
        $this->captainProfileId = (string) $captainProfileId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('captain.' . $this->captainProfileId),
        ];
    }

    /**
     * Broadcast event name matching Flutter EchoService.
     */
    public function broadcastAs(): string
    {
        return 'TripNoLongerAvailable';
    }

    /**
     * Broadcast payload.
     */
    public function broadcastWith(): array
    {
        return [
            'trip_id' => $this->tripId,
            'id' => $this->tripId,
            'event_type' => 'trip_no_longer_available',
            'reason' => 'rejected_by_captain',
        ];
    }
}
