<?php

namespace App\Livewire\Admin;

use App\Models\User;
use App\Models\CaptainProfile;
use App\Services\NotificationService;
use Livewire\Component;
use Livewire\WithPagination;

class PushNotificationsManager extends Component
{
    use WithPagination;

    public $title = '';
    public $body = '';
    public $targetType = 'all'; // all, captains, users, specific
    public $specificUserId = '';

    public function rules()
    {
        return [
            'title' => 'required|string|max:100',
            'body' => 'required|string|max:255',
            'targetType' => 'required|in:all,captains,users,specific',
            'specificUserId' => 'required_if:targetType,specific',
        ];
    }

    public function render()
    {
        // Show real notification history from database
        $history = \Illuminate\Notifications\DatabaseNotification::latest()
            ->take(20)
            ->get()
            ->map(function ($notification) {
                return (object) [
                    'id' => $notification->id,
                    'title' => $notification->data['title'] ?? 'إشعار',
                    'body' => $notification->data['description'] ?? '',
                    'target' => $notification->data['type'] ?? 'عام',
                    'created_at' => $notification->created_at,
                ];
            });

        return view('livewire.admin.push-notifications-manager', [
            'history' => $history
        ]);
    }

    public function sendNotification()
    {
        $this->validate();

        $notificationService = app(NotificationService::class);
        $data = ['type' => 'system'];

        switch ($this->targetType) {
            case 'all':
                $users = User::whereNotNull('fcm_token')->get();
                $count = $notificationService->sendToMultipleUsers($users, $this->title, $this->body, $data);
                session()->flash('success', "تم إرسال الإشعار بنجاح إلى {$count} مستخدم!");
                break;

            case 'captains':
                $captainUserIds = CaptainProfile::pluck('user_id');
                $users = User::whereIn('id', $captainUserIds)->get();
                $count = $notificationService->sendToMultipleUsers($users, $this->title, $this->body, $data);
                session()->flash('success', "تم إرسال الإشعار إلى {$count} كابتن!");
                break;

            case 'users':
                $captainUserIds = CaptainProfile::pluck('user_id');
                $users = User::whereNotIn('id', $captainUserIds)->get();
                $count = $notificationService->sendToMultipleUsers($users, $this->title, $this->body, $data);
                session()->flash('success', "تم إرسال الإشعار إلى {$count} راكب!");
                break;

            case 'specific':
                $user = User::find($this->specificUserId);
                if ($user) {
                    $notificationService->sendToUser($user, $this->title, $this->body, $data);
                    session()->flash('success', "تم إرسال الإشعار إلى {$user->name}!");
                } else {
                    session()->flash('error', 'المستخدم غير موجود.');
                }
                break;
        }

        $this->reset(['title', 'body', 'targetType', 'specificUserId']);
    }
}
