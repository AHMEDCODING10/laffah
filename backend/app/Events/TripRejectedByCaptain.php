<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class TripRejectedByCaptain
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $tripId;
    public $captainProfileId;

    /**
     * Create a new event instance.
     */
    public function __construct($tripId, $captainProfileId)
    {
        $this->tripId = $tripId;
        $this->captainProfileId = $captainProfileId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('channel-name'),
        ];
    }
}
