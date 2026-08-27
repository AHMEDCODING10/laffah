<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendPushNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $user;
    public $title;
    public $body;
    public $data;

    /**
     * Create a new job instance.
     */
    public function __construct(User $user, string $title, string $body, array $data = [])
    {
        $this->user = $user;
        $this->title = $title;
        $this->body = $body;
        $this->data = $data;
    }

    /**
     * Execute the job.
     */
    public function handle(NotificationService $notificationService): void
    {
        try {
            // Calling a new method on NotificationService that handles ONLY the FCM HTTP request
            $notificationService->sendToUserSync($this->user, $this->title, $this->body, $this->data);
        } catch (\Exception $e) {
            Log::error("Failed to send queued push notification to User ID {$this->user->id}: " . $e->getMessage());
        }
    }
}
