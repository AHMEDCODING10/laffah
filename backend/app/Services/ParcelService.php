<?php

namespace App\Services;

use App\Models\Parcel;
use App\Models\CaptainProfile;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Events\ParcelStatusUpdated;
use App\Services\NotificationService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Exception;

class ParcelService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Accept a pending parcel delivery.
     *
     * @param int|string $parcelId
     * @param CaptainProfile $captainProfile
     * @return Parcel
     * @throws Exception
     */
    public function acceptParcel($parcelId, CaptainProfile $captainProfile): Parcel
    {
        $parcel = DB::transaction(function () use ($parcelId, $captainProfile) {
            $parcel = Parcel::where(function ($q) use ($parcelId) {
                $q->where('id', $parcelId)
                  ->orWhere('tracking_code', $parcelId);
            })->lockForUpdate()->first();

            if (!$parcel) {
                throw new Exception("الطرد غير موجود.", 404);
            }

            if ($parcel->status !== 'pending') {
                throw new Exception("تم قبول هذا الطرد مسبقاً من كابتن آخر.", 409);
            }

            $parcel->update([
                'captain_profile_id' => $captainProfile->id,
                'status'             => 'accepted',
                'accepted_at'        => now(),
            ]);

            // [PERFORMANCE FIX ISSUE-1.7]: Run broadcasting and notifications AFTER transaction commit
            DB::afterCommit(function () use ($parcel, $captainProfile) {
                try {
                    event(new ParcelStatusUpdated($parcel));
                } catch (\Throwable $e) {}

                $user = $captainProfile->user;
                $captainName = $user ? $user->name : 'الكابتن';

                // Notify parcel owner
                if ($parcel->user) {
                    try {
                        $this->notificationService->sendToUser(
                            $parcel->user,
                            'تم قبول طلب توصيل الطرد 📦',
                            "وافق الكابتن {$captainName} على توصيل طردك #{$parcel->tracking_code}.",
                            ['type' => 'parcel', 'parcel_id' => (string) $parcel->id]
                        );
                    } catch (\Throwable $e) {}
                }

                // Notify captain
                if ($user) {
                    try {
                        $this->notificationService->sendToUser(
                            $user,
                            'تم قبول توصيل الطرد 📦',
                            "مشوار توصيل طرد جديد #{$parcel->tracking_code} بقيمة " . number_format($parcel->price) . " ر.ي.",
                            ['type' => 'parcel', 'parcel_id' => (string) $parcel->id]
                        );
                    } catch (\Throwable $e) {}
                }
            });

            return $parcel;
        });

        return $parcel->fresh(['captain.user', 'user']);
    }

    /**
     * Update parcel delivery status (arrived_at_pickup, picked_up, in_transit, delivered, cancelled).
     *
     * @param int|string $parcelId
     * @param CaptainProfile $captainProfile
     * @param string $status
     * @param array $extraData
     * @return Parcel
     * @throws Exception
     */
    public function updateStatus($parcelId, CaptainProfile $captainProfile, string $status, array $extraData = []): Parcel
    {
        $parcel = DB::transaction(function () use ($parcelId, $captainProfile, $status, $extraData) {
            $parcel = Parcel::where(function ($q) use ($parcelId) {
                $q->where('id', $parcelId)
                  ->orWhere('tracking_code', $parcelId);
            })
            ->where('captain_profile_id', $captainProfile->id)
            ->lockForUpdate()
            ->first();

            if (!$parcel) {
                throw new Exception("الطرد غير مخصص لهذا الكابتن أو غير موجود.", 404);
            }

            if ($status === 'arrived') {
                $status = 'arrived_at_pickup';
            }

            $updates = [
                'status' => $status,
            ];

            if ($status === 'arrived_at_pickup') {
                $updates['arrived_at_pickup_at'] = now();
            } elseif ($status === 'picked_up') {
                $updates['picked_up_at'] = now();
            } elseif ($status === 'delivered') {
                $updates['delivered_at'] = now();

                // Deduct platform commission from captain wallet atomically with lockForUpdate (ISSUE-1.10)
                $commissionPercent = (float) Cache::remember('setting_commission_percent', 3600, function () {
                    return \App\Models\Setting::where('key', 'commission_percent')->value('value') ?? 15;
                });
                $commission = round($parcel->price * ($commissionPercent / 100), 2);

                $wallet = Wallet::where('user_id', $captainProfile->user_id)->lockForUpdate()->first();
                if (!$wallet) {
                    $wallet = Wallet::create(['user_id' => $captainProfile->user_id, 'balance' => 0, 'currency' => 'YER']);
                }
                $wallet->decrement('balance', $commission);

                Transaction::create([
                    'wallet_id'   => $wallet->id,
                    'parcel_id'   => $parcel->id,
                    'type'        => 'commission',
                    'amount'      => $commission,
                    'status'      => 'completed',
                    'description' => "عمولة لَفَّة عن توصيل طرد #{$parcel->tracking_code}",
                    'reference_id'=> 'COM-PAR-' . $parcel->id . '-' . strtoupper(bin2hex(random_bytes(2))),
                ]);
            }

            $parcel->update($updates);

            // [PERFORMANCE FIX ISSUE-1.7]: Run broadcasting and notifications AFTER transaction commit
            DB::afterCommit(function () use ($parcel, $status, $captainProfile) {
                try {
                    event(new ParcelStatusUpdated($parcel));
                } catch (\Throwable $e) {}

                $user = $captainProfile->user;
                $captainName = $user ? $user->name : 'الكابتن';

                if ($parcel->user) {
                    try {
                        $statusMessages = [
                            'arrived_at_pickup' => [
                                'title' => 'الكابتن وصل إلى موقع الاستلام 📍',
                                'body'  => "وصل الكابتن {$captainName} إلى موقع الاستلام وبانتظار تسليم الطرد #{$parcel->tracking_code}."
                            ],
                            'picked_up' => [
                                'title' => 'تم استلام الطرد بنجاح 📦',
                                'body'  => "قام الكابتن {$captainName} بفحص واستلام طردك #{$parcel->tracking_code} وجاري تجهيز الانطلاق."
                            ],
                            'in_transit' => [
                                'title' => 'الطرد في الطريق إلى المستلم 🛵',
                                'body'  => "الكابتن {$captainName} في طريقه الآن لتسليم الشحنة #{$parcel->tracking_code} للمستلم."
                            ],
                            'delivered' => [
                                'title' => 'تم تسليم الطرد بنجاح! 🎉',
                                'body'  => "أكّد الكابتن {$captainName} تسليم الطرد #{$parcel->tracking_code} بالكامل. شكراً لثقتك بلَفَّة!"
                            ],
                            'cancelled' => [
                                'title' => 'تم إلغاء شحنة الطرد ⚠️',
                                'body'  => "تم إلغاء توصيل الطرد #{$parcel->tracking_code}."
                            ]
                        ];

                        if (isset($statusMessages[$status])) {
                            $this->notificationService->sendToUser(
                                $parcel->user,
                                $statusMessages[$status]['title'],
                                $statusMessages[$status]['body'],
                                ['type' => 'parcel', 'parcel_id' => (string) $parcel->id, 'status' => $status]
                            );
                        }
                    } catch (\Throwable $e) {}
                }
            });

            return $parcel;
        });

        return $parcel->fresh(['captain.user', 'user']);
    }
}
