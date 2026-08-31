<?php

namespace App\Services;

use App\Models\User;
use App\Notifications\TripNotification;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use Exception;
use App\Jobs\SendPushNotification;

class NotificationService
{
    protected ?Messaging $messaging = null;

    public function __construct()
    {
        try {
            $credentialsPath = base_path(config('services.firebase.credentials'));

            if (file_exists($credentialsPath)) {
                $factory = (new Factory)->withServiceAccount($credentialsPath);
                $this->messaging = $factory->createMessaging();
                Log::debug('Firebase Messaging initialized successfully.');
            } else {
                Log::warning("Firebase credentials file not found at: {$credentialsPath}");
            }
        } catch (Exception $e) {
            Log::error("Failed to initialize Firebase Messaging: " . $e->getMessage());
        }
    }

    /**
     * Send push notification to a single user via FCM + store in database.
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): bool
    {
        // Always store in database via Laravel Notifications (FAST)
        $this->storeNotification($user, $title, $body, $data['type'] ?? 'general', $data);

        // Dispatch FCM push to the queue (NON-BLOCKING)
        dispatch(new SendPushNotification($user, $title, $body, $data))->afterResponse();

        return true;
    }

    /**
     * Synchronous method used by the Queue Worker to actually call Firebase API.
     */
    public function sendToUserSync(User $user, string $title, string $body, array $data = []): bool
    {
        if (!$user->fcm_token) {
            Log::info("No FCM token for user ID: {$user->id}");
            return true;
        }

        if (!$this->messaging) {
            Log::warning("Firebase Messaging not initialized");
            return false;
        }

        try {
            $type = $data['type'] ?? 'general';
            $isTripAlert = in_array($type, ['trip_new', 'trip_accepted', 'trip_arrived', 'trip_in_transit']);
            $channelId = $isTripAlert ? 'laffah_trip_alerts_channel' : 'laffah_general_channel';
            
            $androidConfig = AndroidConfig::fromArray([
                'priority' => 'high',
                'notification' => [
                    'channel_id' => $channelId,
                    'sound' => 'default',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
            ]);

            $apnsConfig = ApnsConfig::fromArray([
                'payload' => [
                    'aps' => [
                        'sound' => 'default',
                    ],
                ],
            ]);

            $message = CloudMessage::withTarget('token', $user->fcm_token)
                ->withNotification(Notification::create($title, $body))
                ->withAndroidConfig($androidConfig)
                ->withApnsConfig($apnsConfig)
                ->withData(array_map('strval', $data));

            $this->messaging->send($message);
            Log::info("FCM push sent to user ID: {$user->id}");
            return true;
        } catch (Exception $e) {
            // If token is invalid, clear it
            if (str_contains($e->getMessage(), 'UNREGISTERED') || str_contains($e->getMessage(), 'INVALID_ARGUMENT')) {
                $user->update(['fcm_token' => null]);
                Log::warning("Invalid FCM token cleared for user ID: {$user->id}");
            }
            Log::error("FCM send failed for user ID: {$user->id}: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Send push notification to multiple users (for admin broadcasts).
     */
    public function sendToMultipleUsers(Collection $users, string $title, string $body, array $data = []): int
    {
        $successCount = 0;

        foreach ($users as $user) {
            if ($this->sendToUser($user, $title, $body, $data)) {
                $successCount++;
            }
        }

        Log::info("Bulk notification sent: {$successCount}/{$users->count()} succeeded.");
        return $successCount;
    }

    /**
     * Send push notification to a topic (e.g., 'all_captains', 'all_passengers').
     */
    public function sendToTopic(string $topic, string $title, string $body, array $data = []): bool
    {
        if (!$this->messaging) {
            Log::warning("Firebase Messaging not initialized — topic notification skipped.");
            return false;
        }

        try {
            $message = CloudMessage::withTarget('topic', $topic)
                ->withNotification(Notification::create($title, $body))
                ->withData(array_map('strval', $data));

            $this->messaging->send($message);
            Log::info("FCM topic notification sent to: {$topic}");
            return true;
        } catch (Exception $e) {
            Log::error("FCM topic send failed for '{$topic}': " . $e->getMessage());
            return false;
        }
    }

    /**
     * Store notification in database using Laravel Notifications system.
     */
    private function storeNotification(User $user, string $title, string $body, string $type, array $data = []): void
    {
        try {
            $user->notify(new TripNotification($title, $body, $type, $data));
        } catch (Exception $e) {
            Log::error("Failed to store notification for user ID: {$user->id}: " . $e->getMessage());
        }
    }
}
