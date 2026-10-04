<?php

namespace App\Events;

use App\Models\CaptainProfile;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CaptainForcedOffline implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $captainId;
    public $reason;

    public function __construct($captainId, string $reason = 'inactivity_timeout')
    {
        $this->captainId = (string) $captainId;
        $this->reason = $reason;
    }

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('captain.' . $this->captainId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'CaptainForcedOffline';
    }

    public function broadcastWith(): array
    {
        return [
            'captain_id' => $this->captainId,
            'is_online' => false,
            'reason' => $this->reason,
            'message' => 'تم تحويل حالتك إلى غير متصل تلقائياً لعدم تحديث الموقع لفترة طويلة',
            'timestamp' => now()->toIso8601String(),
        ];
    }
}
