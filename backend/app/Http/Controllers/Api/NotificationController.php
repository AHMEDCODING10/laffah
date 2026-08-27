<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get paginated notifications for the authenticated user.
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $perPage = $request->get('per_page', 20);

        $notifications = $user->notifications()
            ->latest()
            ->paginate($perPage);

        $formatted = $notifications->getCollection()->map(function ($notification) {
            return [
                'id' => $notification->id,
                'title' => $notification->data['title'] ?? 'إشعار',
                'description' => $notification->data['description'] ?? '',
                'timeTag' => $notification->created_at->diffForHumans(),
                'icon' => $notification->data['icon'] ?? 'bell',
                'isRead' => !is_null($notification->read_at),
                'type' => $notification->data['type'] ?? 'general',
                'tripId' => $notification->data['trip_id'] ?? null,
                'captainName' => $notification->data['captain_name'] ?? $notification->data['extra']['captain_name'] ?? null,
                'extra' => $notification->data['extra'] ?? [],
                'createdAt' => $notification->created_at->toISOString(),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $formatted,
            'pagination' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
            ],
        ]);
    }

    /**
     * Get unread notifications count.
     */
    public function unreadCount(Request $request)
    {
        $count = $request->user()->unreadNotifications()->count();

        return response()->json([
            'status' => 'success',
            'data' => ['unread_count' => $count],
        ]);
    }

    /**
     * Mark a specific notification as read.
     */
    public function markAsRead(Request $request, $id)
    {
        $notification = $request->user()
            ->notifications()
            ->where('id', $id)
            ->first();

        if (!$notification) {
            return response()->json([
                'status' => 'error',
                'message' => 'الإشعار غير موجود.',
            ], 404);
        }

        $notification->markAsRead();

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديد الإشعار كمقروء.',
        ]);
    }

    /**
     * Mark all notifications as read.
     */
    public function markAllAsRead(Request $request)
    {
        $request->user()->unreadNotifications->markAsRead();

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديد جميع الإشعارات كمقروءة.',
        ]);
    }

    /**
     * Delete a specific notification.
     */
    public function destroy(Request $request, $id)
    {
        $notification = $request->user()
            ->notifications()
            ->where('id', $id)
            ->first();

        if (!$notification) {
            return response()->json([
                'status' => 'error',
                'message' => 'الإشعار غير موجود.',
            ], 404);
        }

        $notification->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف الإشعار بنجاح.',
        ]);
    }

    /**
     * Delete all notifications for the authenticated user.
     */
    public function destroyAll(Request $request)
    {
        $request->user()->notifications()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم مسح جميع الإشعارات بنجاح.',
        ]);
    }
}
