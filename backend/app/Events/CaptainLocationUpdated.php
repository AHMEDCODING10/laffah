<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CaptainLocationUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $captainId;
    public $captain_id;
    public $latitude;
    public $longitude;
    public $lat;
    public $lng;
    public $heading;
    public $speed;
    public $updated_at;

    public function __construct($captainId, $lat, $lng, $heading = 0.0, $speed = 0.0)
    {
        $this->captainId = (string) $captainId;
        $this->captain_id = (string) $captainId;
        $this->latitude = (float) $lat;
        $this->longitude = (float) $lng;
        $this->lat = (float) $lat;
        $this->lng = (float) $lng;
        $this->heading = (float) ($heading ?? 0.0);
        $this->speed = (float) ($speed ?? 0.0);
        $this->updated_at = now()->toIso8601String();
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new Channel('captain-location.' . $this->captainId),
            new Channel('captains-locations'),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'CaptainLocationUpdated';
    }

    /**
     * Get the data to broadcast.
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'captain_id' => $this->captain_id,
            'captainId' => $this->captainId,
            'lat' => $this->lat,
            'lng' => $this->lng,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'heading' => $this->heading,
            'speed' => $this->speed,
            'updated_at' => $this->updated_at,
        ];
    }
}