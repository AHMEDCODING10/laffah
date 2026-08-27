<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class TripNotification extends Notification
{
    use Queueable;

    protected string $title;
    protected string $body;
    protected string $type;
    protected array $extraData;

    /**
     * Create a new notification instance.
     *
     * @param string $title    Notification title
     * @param string $body     Notification body/description
     * @param string $type     Type: trip_new, trip_accepted, trip_arrived, trip_started, trip_completed, trip_cancelled, system, promo
     * @param array  $extraData Additional data (trip_id, captain_name, etc.)
     */
    public function __construct(string $title, string $body, string $type = 'general', array $extraData = [])
    {
        $this->title = $title;
        $this->body = $body;
        $this->type = $type;
        $this->extraData = $extraData;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification (stored in `notifications` table).
     */
    public function toArray($notifiable): array
    {
        return [
            'title' => $this->title,
            'description' => $this->body,
            'type' => $this->type,
            'icon' => $this->getIconForType($this->type),
            'trip_id' => $this->extraData['trip_id'] ?? null,
            'extra' => $this->extraData,
        ];
    }

    /**
     * Map notification type to icon name for the frontend.
     */
    private function getIconForType(string $type): string
    {
        return match ($type) {
            'trip_new' => 'bike',
            'trip_accepted' => 'check',
            'trip_arrived' => 'location',
            'trip_started' => 'bike',
            'trip_completed' => 'star',
            'trip_cancelled' => 'cancel',
            'promo' => 'offer',
            'system' => 'shield',
            default => 'bell',
        };
    }
}
