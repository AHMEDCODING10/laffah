<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CaptainProfile;
use App\Models\CaptainLocation;
use App\Models\Wallet;
use App\Models\Document;
use App\Models\Trip;
use App\Models\Setting;
use App\Services\TripService;
use Illuminate\Support\Facades\Storage;
use Exception;

class CaptainController extends Controller
{
    /**
     * Update current real-time GPS location of captain.
     */
    public function updateLocation(Request $request)
    {
        $lat = $request->input('latitude') ?? $request->input('lat');
        $lng = $request->input('longitude') ?? $request->input('lng');
        $heading = $request->input('heading') ?? 0;
        $speed = $request->input('speed') ?? 0;

        if ($lat === null || $lng === null || !is_numeric($lat) || !is_numeric($lng)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'The latitude and longitude fields are required and must be numeric.',
                'errors'  => [
                    'latitude'  => ['The latitude field is required.'],
                    'longitude' => ['The longitude field is required.'],
                ]
            ], 422);
        }

        $lat = (float) $lat;
        $lng = (float) $lng;

        if ($lat < 12.0 || $lat > 19.5 || $lng < 41.5 || $lng > 54.5) {
            return response()->json([
                'status'  => 'error',
                'message' => 'الإحداثيات المرسلة تقع خارج النطاق الجغرافي للجمهورية اليمنية (12.0 - 19.5 N, 41.5 - 54.5 E).',
            ], 422);
        }

        $user = $request->user();
        $captainProfile = $user->captainProfile;

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'لم يتم العثور على ملف تعريف الكابتن.'], 404);
        }

        $location = CaptainLocation::updateOrCreate(
            ['captain_profile_id' => $captainProfile->id],
            [
                'latitude'        => $lat,
                'longitude'       => $lng,
                'heading'         => (float) $heading,
                'speed'           => (float) $speed,
                'last_updated_at' => now(),
            ]
        );

        // Broadcast location update
        try {
            event(new \App\Events\CaptainLocationUpdated(
                $captainProfile->id,
                $lat,
                $lng,
                (float) $heading
            ));
        } catch (\Exception $e) {
            // Non-blocking if broadcast driver is not configured
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم تحديث الموقع بنجاح.',
            'data'    => $location
        ]);
    }

    /**
     * Toggle online/offline status for Captain.
     * Enforces negative balance threshold check before going online.
     */
    public function toggleOnlineStatus(Request $request)
    {
        $request->validate([
            'is_online' => 'required|boolean',
            'latitude'  => 'nullable|numeric|between:12.0,19.5',
            'longitude' => 'nullable|numeric|between:41.5,54.5',
        ]);

        $user = $request->user();
        $captainProfile = $user->captainProfile;

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'لم يتم العثور على ملف تعريف الكابتن.'], 404);
        }

        $isOnline = (bool) $request->is_online;

        // If trying to go online, verify wallet balance is not below debt cap (-2000 YER)
        if ($isOnline) {
            $wallet = Wallet::where('user_id', $user->id)->first();
            if ($wallet && $wallet->balance < TripService::MAX_CAPTAIN_DEBT) {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'لا يمكنك بدء العمل لأن رصيدك سالب (' . number_format($wallet->balance) . ' ريال) وتجاوز سقف العمولة المسموح به. يرجى شحن محفظتك للاستمرار.'
                ], 403);
            }
        }

        $captainProfile->update([
            'is_online' => $isOnline,
        ]);

        $lat = $request->latitude ?? $request->lat ?? $request->input('currentLat');
        $lng = $request->longitude ?? $request->lng ?? $request->input('currentLng');

        if ($lat !== null && $lng !== null && $isOnline) {
            CaptainLocation::updateOrCreate(
                ['captain_profile_id' => $captainProfile->id],
                [
                    'latitude'        => (float) $lat,
                    'longitude'       => (float) $lng,
                    'last_updated_at' => now(),
                ]
            );
        }

        return response()->json([
            'status'  => 'success',
            'message' => $isOnline ? 'أنت الآن متصل ومتاح لاستقبال المشاوير 🛵' : 'أنت الآن غير متصل (أوفلاين).',
            'data'    => [
                'id'             => $captainProfile->id,
                'is_online'      => (bool) $captainProfile->is_online,
                'lat'            => $lat !== null ? (float) $lat : 0.0,
                'lng'            => $lng !== null ? (float) $lng : 0.0,
                'status_message' => $isOnline ? 'أنت متصل ومتاح لاستقبال المشاوير' : 'أنت الآن غير متصل',
            ]
        ]);
    }

    /**
     * Get captain verification documents and verification status.
     */
    public function getDocuments(Request $request)
    {
        $user = $request->user();
        $captainProfile = $user?->captainProfile;

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'لم يتم العثور على ملف تعريف الكابتن.'], 404);
        }

        $documents = Document::where('captain_profile_id', $captainProfile->id)->get();

        $docList = $documents->map(function ($doc) {
            return [
                'id'               => $doc->id,
                'type'             => $doc->type,
                'status'           => $doc->status, // pending, approved, rejected
                'rejection_reason' => $doc->rejection_reason,
                'file_url'         => url('/api/v1/captain/documents/' . $doc->id),
                'created_at'       => $doc->created_at?->toIso8601String(),
                'updated_at'       => $doc->updated_at?->toIso8601String(),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data'   => [
                'is_verified' => (bool) $captainProfile->is_verified,
                'documents'   => $docList,
            ]
        ]);
    }

    /**
     * Upload captain verification documents.
     */
    public function uploadDocuments(Request $request)
    {
        // Support both 'type' (from mobile app) and 'document_type' (from API spec) with full alias normalization
        $docType = $request->input('document_type') ?? $request->input('type');
        $typeMapping = [
            'drivers_license'      => 'driving_license',
            'license'              => 'driving_license',
            'identity'             => 'id_card',
            'id_card'              => 'id_card',
            'vehicle_card'         => 'bike_license',
            'vehicle_ownership'    => 'bike_license',
            'vehicle_registration' => 'bike_license',
            'bike_license'         => 'bike_license',
            'inspection'           => 'inspection',
            'criminal_record'      => 'criminal_record',
            'insurance'            => 'insurance',
        ];
        if (isset($typeMapping[$docType])) {
            $docType = $typeMapping[$docType];
        }
        $request->merge(['document_type' => $docType]);

        $request->validate([
            'document_type' => 'required|string|in:id_card,driving_license,bike_license,inspection,criminal_record,insurance',
            'file'          => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240',
        ]);

        $user = $request->user();
        $captainProfile = $user?->captainProfile;

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'لم يتم العثور على ملف الكابتن.'], 404);
        }

        $path = $request->file('file')->store('captain_documents', 'local');

        $doc = Document::updateOrCreate(
            [
                'captain_profile_id' => $captainProfile->id,
                'type'               => $request->document_type,
            ],
            [
                'file_path'        => $path,
                'status'           => 'pending',
                'rejection_reason' => null,
            ]
        );

        return response()->json([
            'status'  => 'success',
            'message' => 'تم رفع الوثيقة بنجاح وهي قيد المراجعة والتدقيق.',
            'data'    => [
                'id'               => $doc->id,
                'type'             => $doc->type,
                'status'           => $doc->status,
                'rejection_reason' => $doc->rejection_reason,
                'file_url'         => url('/api/v1/captain/documents/' . $doc->id),
                'created_at'       => $doc->created_at?->toIso8601String(),
                'updated_at'       => $doc->updated_at?->toIso8601String(),
            ]
        ]);
    }

    /**
     * Authenticated preview/download for captain documents.
     */
    public function showDocument(Request $request, $id)
    {
        $user = $request->user();
        if (!$user && $request->has('token')) {
            try {
                $user = auth('api')->setToken($request->query('token'))->user();
            } catch (\Exception $e) {}
        }
        $captainProfile = $user?->captainProfile;

        $doc = Document::findOrFail($id);

        $isOwner = $captainProfile && $doc->captain_profile_id == $captainProfile->id;
        $isAdmin = $user && ($user->hasRole('admin') || !empty($user->is_admin));

        if (!$isOwner && !$isAdmin) {
            return response()->json(['status' => 'error', 'message' => 'غير مصرح لك بالاطلاع على هذه الوثيقة.'], 403);
        }

        if (\Illuminate\Support\Facades\Storage::disk('local')->exists($doc->file_path)) {
            return response()->file(\Illuminate\Support\Facades\Storage::disk('local')->path($doc->file_path));
        }

        // Backward compatibility for legacy public files
        if (\Illuminate\Support\Facades\Storage::disk('public')->exists($doc->file_path)) {
            return response()->file(\Illuminate\Support\Facades\Storage::disk('public')->path($doc->file_path));
        }

        return response()->json(['status' => 'error', 'message' => 'ملف الوثيقة غير موجود.'], 404);
    }

    /**
     * Get captain bonus and achievements data.
     */
    public function getBonus(Request $request)
    {
        $user = $request->user();
        $captainProfile = $user->captainProfile;

        if (!$captainProfile) {
            return response()->json(['status' => 'error', 'message' => 'لم يتم العثور على ملف تعريف الكابتن.'], 404);
        }

        $startOfToday = \Carbon\Carbon::today()->startOfDay();
        $endOfToday   = \Carbon\Carbon::today()->endOfDay();

        $completedToday = Trip::where('captain_profile_id', $captainProfile->id)
            ->where('status', 'completed')
            ->where('completed_at', '>=', $startOfToday)
            ->where('completed_at', '<=', $endOfToday)
            ->count();

        $dailyTarget = (int) (Setting::where('key', 'daily_trip_target')->value('value') ?? 10);
        $bonusAmount = (int) (Setting::where('key', 'daily_bonus_amount')->value('value') ?? 2500);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'total_trips'         => (int) ($captainProfile->total_trips ?? 0),
                'rating'              => (float) ($captainProfile->rating ?? 5.0),
                'daily_target'        => $dailyTarget,
                'dailyTarget'         => $dailyTarget,
                'target_trips'        => $dailyTarget,
                'daily_completed'     => $completedToday,
                'completed_today'     => $completedToday,
                'completedToday'      => $completedToday,
                'completed_trips'     => $completedToday,
                'completedTripsToday' => $completedToday,
                'bonus_amount'        => $bonusAmount,
                'bonusAmount'         => $bonusAmount,
                'bonus_earned'        => $completedToday >= $dailyTarget ? $bonusAmount : 0,
                'level'               => $completedToday >= $dailyTarget ? 'الكابتن الذهبي' : 'الكابتن الفضي',
                'points'              => $completedToday * 50,
            ]
        ]);
    }
}