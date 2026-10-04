<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TripService;
use App\Http\Requests\Trip\EstimateTripRequest;
use App\Http\Requests\Trip\CreateTripRequest;
use App\Http\Requests\Trip\UpdateTripStatusRequest;
use App\Http\Resources\TripResource;
use App\Models\Trip;
use App\Models\CaptainLocation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TripController extends Controller
{
    protected $tripService;
    protected $parcelService;

    public function __construct(TripService $tripService, \App\Services\ParcelService $parcelService)
    {
        $this->tripService = $tripService;
        $this->parcelService = $parcelService;
    }

    public function estimate(EstimateTripRequest $request)
    {
        try {
            $estimate = $this->tripService->estimate($request->validated());
            return response()->json([
                'status' => 'success',
                'data' => $estimate
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $statusCode);
        }
    }

    public function create(CreateTripRequest $request)
    {
        try {
            $trip = $this->tripService->createTrip($request->user()->id, $request->validated());
            return response()->json([
                'status' => 'success',
                'message' => 'تم إنشاء طلب المشوار بنجاح، جاري البحث عن كابتن...',
                'data' => new TripResource($trip)
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $statusCode);
        }
    }

    public function show(Request $request, $id)
    {
        try {
            $user = $request->user();
            $captainProfileId = $user?->captainProfile?->id;

            $trip = Trip::with(['stops', 'passenger', 'captain.user'])->find($id);
            if ($trip) {
                $isOwner = $user && $trip->user_id == $user->id;
                $isAssignedCaptain = $captainProfileId && $trip->captain_profile_id == $captainProfileId;
                $isPendingAvailable = $trip->status === 'pending' && is_null($trip->captain_profile_id) && $captainProfileId;
                $isAdmin = $user && ($user->hasRole('admin') || !empty($user->is_admin));

                if (!$isOwner && !$isAssignedCaptain && !$isPendingAvailable && !$isAdmin) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'غير مصرح لك بالاطلاع على تفاصيل هذا المشوار.'
                    ], 403);
                }

                return response()->json([
                    'status' => 'success',
                    'data' => new TripResource($trip)
                ]);
            }

            // Fallback: Check if it's a parcel
            $parcel = \App\Models\Parcel::with(['captain.user'])->find($id);
            if ($parcel) {
                $isOwner = $user && $parcel->user_id == $user->id;
                $isAssignedCaptain = $captainProfileId && $parcel->captain_profile_id == $captainProfileId;
                $isPendingAvailable = $parcel->status === 'pending' && is_null($parcel->captain_profile_id) && $captainProfileId;
                $isAdmin = $user && ($user->hasRole('admin') || !empty($user->is_admin));

                if (!$isOwner && !$isAssignedCaptain && !$isPendingAvailable && !$isAdmin) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'غير مصرح لك بالاطلاع على تفاصيل هذا الطرد.'
                    ], 403);
                }

                $captainUser = $parcel->captain?->user;
                return response()->json([
                    'status' => 'success',
                    'data' => [
                        'id' => (string) $parcel->id,
                        'status' => $parcel->status,
                        'type' => 'delivery',
                        'isParcel' => true,
                        'title' => 'طلب توصيل طرد 📦',
                        'price' => (float) $parcel->price,
                        'grossFare' => (float) $parcel->price,
                        'estimated_price' => (float) $parcel->price,
                        'pickup_address' => $parcel->pickup_address,
                        'dropoff_address' => $parcel->dropoff_address,
                        'pickup_latitude' => (float) $parcel->pickup_latitude,
                        'pickup_longitude' => (float) $parcel->pickup_longitude,
                        'dropoff_latitude' => (float) $parcel->dropoff_latitude,
                        'dropoff_longitude' => (float) $parcel->dropoff_longitude,
                        'passengerName' => $parcel->sender_name ?? 'مرسل',
                        'passengerPhone' => $parcel->sender_phone ?? '',
                        'receiverName' => $parcel->receiver_name ?? 'مستلم',
                        'receiverPhone' => $parcel->receiver_phone ?? '',
                        'captain_name' => $captainUser?->name ?? null,
                        'captain_phone' => $captainUser?->phone ?? null,
                        'vehicle_model' => $parcel->captain?->vehicle_model ?? null,
                        'vehicle_plate' => $parcel->captain?->plate_number ?? null,
                        'rating' => $parcel->captain?->rating ?? 5.0,
                        'timeTag' => $parcel->created_at ? $parcel->created_at->diffForHumans() : 'الآن',
                    ]
                ]);
            }

            return response()->json([
                'status' => 'error',
                'message' => 'المشوار أو الطرد غير موجود.'
            ], 404);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 400);
        }
    }

    public function accept(Request $request, $id)
    {
        try {
            // Handle if client sent accept: false to this endpoint
            if ($request->has('accept') && !$request->boolean('accept')) {
                return $this->reject($request, $id);
            }

            if (!$request->user()->hasRole('captain') || !$request->user()->captainProfile) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'غير مصرح لك بقبول هذا المشوار ككابتن.'
                ], 403);
            }
            // Check if it's a trip first
            $tripExists = Trip::where('id', $id)->exists();
            if (!$tripExists) {
                // Check if it is a parcel request
                $parcel = \App\Models\Parcel::where('id', $id)->first();
                if ($parcel) {
                    $acceptedParcel = $this->parcelService->acceptParcel($id, $request->user()->captainProfile);
                    return response()->json([
                        'status' => 'success',
                        'message' => 'تم قبول توصيل الطرد بنجاح!',
                        'data' => $acceptedParcel,
                    ]);
                }
            }

            $trip = $this->tripService->acceptTrip($id, $request->user()->captainProfile->id);
            return response()->json([
                'status' => 'success',
                'message' => 'تم قبول المشوار بنجاح.',
                'data' => new TripResource($trip)
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json([
                'status' => 'error',
                'error_code' => 'TRIP_ACCEPT_FAILED',
                'message' => $e->getMessage()
            ], $statusCode);
        }
    }

    public function reject(Request $request, $id)
    {
        try {
            $this->tripService->rejectTrip($id, $request->user()->captainProfile->id);
            return response()->json([
                'status'  => 'success',
                'message' => 'تم رفض طلب المشوار بنجاح.',
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function updateStatus(UpdateTripStatusRequest $request, $id)
    {
        try {
            $trip = $this->tripService->updateStatus(
                $id,
                $request->user()->captainProfile->id,
                $request->status
            );
            return response()->json([
                'status' => 'success',
                'message' => 'تم تحديث حالة المشوار بنجاح.',
                'data' => new TripResource($trip)
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $statusCode);
        }
    }

    public function cancel(Request $request, $id)
    {
        try {
            $reason = $request->input('reason', 'تم الإلغاء');
            $type = $request->input('type', 'trip');

            if ($type === 'parcel') {
                $parcel = \App\Models\Parcel::findOrFail($id);
                $user = $request->user();
                
                // Verify ownership or captaincy
                $isPassenger = $parcel->user_id === $user->id;
                $isAssignedCaptain = $user->captainProfile && $parcel->captain_profile_id === $user->captainProfile->id;
                
                if (!$isPassenger && !$isAssignedCaptain) {
                    throw new \Exception("غير مصرح لك بإلغاء هذا الطرد.", 403);
                }

                if ($parcel->status === 'delivered' || $parcel->status === 'cancelled') {
                    throw new \Exception("لا يمكن إلغاء طرد مكتمل أو ملغي مسبقاً.", 400);
                }

                $parcel->update([
                    'status' => 'cancelled',
                    'cancellation_reason' => $reason,
                ]);

                return response()->json([
                    'status' => 'success',
                    'message' => 'تم إلغاء الطرد بنجاح.',
                    'data' => $parcel
                ]);
            }

            $trip = $this->tripService->cancelTrip($id, $request->user(), $reason);
            return response()->json([
                'status' => 'success',
                'message' => 'تم إلغاء المشوار بنجاح.',
                'data' => new TripResource($trip)
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $statusCode);
        }
    }

    public function retrySearch(Request $request, $id)
    {
        try {
            $trip = $this->tripService->retryTripSearch($id, $request->user());
            return response()->json([
                'status'  => 'success',
                'message' => 'تم إعادة إطلاق البحث وإشعار الكباتن القريبين بنجاح.',
                'data'    => new TripResource($trip)
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $statusCode);
        }
    }

    public function rate(Request $request, $id)
    {
        try {
            $review = $request->input('review') ?? $request->input('comment');
            $request->merge(['review' => $review]);

            $request->validate([
                'rating' => 'required|numeric|min:1|max:5',
                'review' => 'nullable|string|max:500'
            ]);
            $trip = $this->tripService->rateTrip(
                $id,
                $request->user(),
                $request->rating,
                $request->review
            );
            return response()->json([
                'status' => 'success',
                'message' => 'تم تسجيل التقييم بنجاح.',
                'data' => new TripResource($trip)
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode();
            $statusCode = ($code >= 400 && $code < 600) ? $code : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $statusCode);
        }
    }

    public function history(Request $request)
    {
        $user = $request->user();
        $statusFilter = trim($request->query('status_filter') ?? $request->query('status') ?? '');
        $perPage = (int) ($request->query('per_page', 30));
        $page = (int) ($request->query('page', 1));

        $tripQuery = Trip::with(['stops', 'passenger', 'captain.user'])
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc');

        $parcelQuery = \App\Models\Parcel::with(['captain.user', 'user'])
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc');

        if ($user->captainProfile) {
            $tripQuery->where('captain_profile_id', $user->captainProfile->id);
            $parcelQuery->where('captain_profile_id', $user->captainProfile->id);
        } else {
            $tripQuery->where('user_id', $user->id);
            $parcelQuery->where('user_id', $user->id);
        }

        if (!empty($statusFilter) && $statusFilter !== 'all' && $statusFilter !== 'الكل') {
            if ($statusFilter === 'completed' || $statusFilter === 'finished' || $statusFilter === 'مكتملة' || $statusFilter === 'تم الانتهاء' || $statusFilter === 'تم التسليم' || $statusFilter === 'delivered') {
                $tripQuery->where('status', 'completed');
                $parcelQuery->where('status', 'delivered');
            } elseif ($statusFilter === 'cancelled' || $statusFilter === 'ملغاة' || $statusFilter === 'ملغية' || $statusFilter === 'canceled') {
                $tripQuery->where('status', 'cancelled');
                $parcelQuery->where('status', 'cancelled');
            } elseif ($statusFilter === 'active' || $statusFilter === 'in_progress' || $statusFilter === 'قيد التنفيذ' || $statusFilter === 'جارية' || $statusFilter === 'نشطة') {
                $tripQuery->whereIn('status', ['accepted', 'arrived', 'in_transit']);
                $parcelQuery->whereIn('status', ['accepted', 'arrived_at_pickup', 'picked_up', 'in_transit']);
            } else {
                $tripQuery->where('status', $statusFilter);
                $parcelQuery->where('status', $statusFilter);
            }
        }

        $tripCount = (clone $tripQuery)->count();
        $parcelCount = (clone $parcelQuery)->count();
        $total = $tripCount + $parcelCount;

        // Efficient windowed pagination: fetch only the necessary slice instead of 1,000 models
        $offset = max(0, ($page - 1) * $perPage);
        $trips = $tripQuery->skip($offset)->take($perPage)->get();
        $parcels = $parcelQuery->skip($offset)->take($perPage)->get();

        $tripData = TripResource::collection($trips)->resolve();
        $parcelData = $parcels->map(function ($p) {
            return $this->formatParcelForApp($p);
        })->toArray();

        $merged = collect($tripData)->concat($parcelData)->sortByDesc('created_at')->values();
        $paginated = $merged->slice(0, $perPage)->values();

        return response()->json([
            'status' => 'success',
            'data'   => $paginated,
            'pagination' => [
                'current_page' => $page,
                'last_page'    => max(1, (int) ceil($total / $perPage)),
                'per_page'     => $perPage,
                'total'        => $total,
            ],
        ]);
    }

    public function nearbyRequests(Request $request)
    {
        $user = $request->user();
        $lat = $request->input('latitude') ?? $request->input('lat');
        $lng = $request->input('longitude') ?? $request->input('lng');

        if (!$lat || !$lng) {
            if ($user && $user->captainProfile) {
                $location = CaptainLocation::where('captain_profile_id', $user->captainProfile->id)->first();
                if ($location) {
                    $lat = $location->latitude;
                    $lng = $location->longitude;
                }
            }
        }

        // Debt limit check
        if ($user) {
            $wallet = \App\Models\Wallet::where('user_id', $user->id)->first();
            if ($wallet && $wallet->balance < \App\Services\TripService::MAX_CAPTAIN_DEBT) {
                return response()->json([
                    'status' => 'success',
                    'data'   => [],
                    'message'=> 'لقد تجاوزت سقف المديونية المسموح به. يرجى سداد المديونية لتتمكن من استقبال طلبات جديدة.'
                ]);
            }
        }

        // Query fresh, pending, unassigned trips within the last 3 minutes using Spatial Bounding Box
        $tripRadius = 30.0;
        $tripQuery = Trip::where('status', 'pending')
            ->whereNull('captain_profile_id')
            ->where('created_at', '>=', now()->subMinutes(3))
            ->with(['stops', 'passenger'])
            ->orderBy('created_at', 'desc');

        if ($lat && $lng) {
            $latDelta = $tripRadius / 111.045;
            $lngDelta = $tripRadius / (111.045 * max(0.1, cos(deg2rad((float)$lat))));
            $tripQuery->whereBetween('pickup_latitude', [(float)$lat - $latDelta, (float)$lat + $latDelta])
                      ->whereBetween('pickup_longitude', [(float)$lng - $lngDelta, (float)$lng + $lngDelta]);
        }

        $trips = $tripQuery->take(30)->get();

        if ($lat && $lng) {
            $trips = $trips->filter(function ($trip) use ($lat, $lng, $tripRadius) {
                if (!$trip->pickup_latitude || !$trip->pickup_longitude) return true;
                $dist = \App\Helpers\GeoHelper::haversineDistance((float)$lat, (float)$lng, (float)$trip->pickup_latitude, (float)$trip->pickup_longitude);
                return $dist <= $tripRadius;
            })->values();
        }

        $tripData = TripResource::collection($trips)->resolve();

        // Also fetch fresh pending parcels within last 3 minutes using Spatial Bounding Box (15km radius)
        $parcelRadius = 15.0;
        $parcelQuery = \App\Models\Parcel::where('status', 'pending')
            ->whereNull('captain_profile_id')
            ->where('created_at', '>=', now()->subMinutes(3))
            ->with('user')
            ->latest();

        if ($lat && $lng) {
            $pLatDelta = $parcelRadius / 111.045;
            $pLngDelta = $parcelRadius / (111.045 * max(0.1, cos(deg2rad((float)$lat))));
            $parcelQuery->whereBetween('pickup_latitude', [(float)$lat - $pLatDelta, (float)$lat + $pLatDelta])
                        ->whereBetween('pickup_longitude', [(float)$lng - $pLngDelta, (float)$lng + $pLngDelta]);
        }

        $parcels = $parcelQuery->take(20)->get();

        if ($lat && $lng) {
            $parcels = $parcels->filter(function ($p) use ($lat, $lng, $parcelRadius) {
                if (!$p->pickup_latitude || !$p->pickup_longitude) return true;
                $dist = \App\Helpers\GeoHelper::haversineDistance((float)$lat, (float)$lng, (float)$p->pickup_latitude, (float)$p->pickup_longitude);
                return $dist <= $parcelRadius;
            })->values();
        }

        $parcelData = $parcels->map(function ($p) {
            return $this->formatParcelForApp($p);
        })->toArray();

        $allRequests = array_merge($tripData, $parcelData);

        return response()->json([
            'status' => 'success',
            'data'   => $allRequests
        ]);
    }

    private function formatParcelForApp($p)
    {
        $dist = (float) ($p->distance_km ?? 2.5);
        $estDuration = max(1, (int) round($dist * 2.5));
        $price = (float) $p->price;
        $code = $p->tracking_code ?? $p->id;

        return [
            'id' => (string) $p->id,
            'status' => $p->status,
            'type' => 'delivery',
            'isParcel' => true,
            'is_parcel' => true,
            'title' => "توصيل طرد #{$code} 📦",
            'description' => ($p->pickup_address ?? 'صنعاء') . ' ← ' . ($p->dropoff_address ?? 'صنعاء'),
            'parcel_type' => $p->parcel_type ?? 'طرد',
            'size' => $p->size ?? 'متوسط',
            'tracking_code' => $p->tracking_code ?? ('LF-P' . $p->id),
            'trackingCode' => $p->tracking_code ?? ('LF-P' . $p->id),
            'parcelType' => $p->parcel_type ?? 'طرد',
            'notes' => $p->notes ?? '',

            'price' => $price,
            'estimated_price' => $price,
            'final_price' => $price,
            'grossFare' => $price,
            'distance_km' => $dist,
            'distance' => number_format($dist, 1) . ' كم',
            'eta' => "~{$estDuration} دقيقة",
            'duration' => "{$estDuration} د",
            'timeTag' => $p->created_at ? $p->created_at->diffForHumans() : 'الآن',
            'created_at' => $p->created_at ? $p->created_at->toISOString() : null,
            'updated_at' => $p->updated_at ? $p->updated_at->toISOString() : null,
            'currency' => 'YER',

            'pickup' => $p->pickup_address ?? 'موقع الاستلام',
            'pickup_address' => $p->pickup_address ?? 'موقع الاستلام',
            'pickup_location' => $p->pickup_address ?? 'موقع الاستلام',
            'pickup_latitude' => (float) ($p->pickup_latitude ?? 15.3694),
            'pickup_longitude' => (float) ($p->pickup_longitude ?? 44.1910),

            'dropoff' => $p->dropoff_address ?? 'موقع التسليم',
            'dropoff_address' => $p->dropoff_address ?? 'موقع التسليم',
            'dropoff_location' => $p->dropoff_address ?? 'موقع التسليم',
            'dropoff_latitude' => (float) ($p->dropoff_latitude ?? 15.3521),
            'dropoff_longitude' => (float) ($p->dropoff_longitude ?? 44.2014),

            'passengerName' => $p->sender_name ?? $p->user?->name ?? 'المرسل',
            'passengerPhone' => $p->sender_phone ?? $p->user?->phone ?? '',
            'sender_name' => $p->sender_name ?? $p->user?->name ?? 'المرسل',
            'sender_phone' => $p->sender_phone ?? $p->user?->phone ?? '',
            'receiverName' => $p->receiver_name ?? 'المستلم',
            'receiverPhone' => $p->receiver_phone ?? '',
            'receiver_name' => $p->receiver_name ?? 'المستلم',
            'receiver_phone' => $p->receiver_phone ?? '',
            
            'passengerRating' => 5.0,
            'captainName' => $p->captain?->user?->name,
            'captainPhone' => $p->captain?->user?->phone,
            'captainRating' => (float) ($p->captain?->rating ?? 5.0),
            'captain' => $p->captain ? [
                'id' => $p->captain->id,
                'name' => $p->captain->user?->name ?? 'الكابتن',
                'phone' => $p->captain->user?->phone,
                'vehicle_model' => $p->captain->vehicle_model ?? 'دراجة نارية',
                'plate_number' => $p->captain->plate_number ?? '',
                'rating' => (float) ($p->captain->rating ?? 5.0),
                'user' => [
                    'id' => $p->captain->user?->id,
                    'name' => $p->captain->user?->name ?? 'الكابتن',
                    'phone' => $p->captain->user?->phone,
                ],
            ] : null,
            'stops' => [],
        ];
    }

    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->user();

            // Strict IDOR & Financial Audit Protection: Prevent hard delete of financial records
            if (!$user->hasRole('admin') && empty($user->is_admin)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'غير مصرح بحذف أو تصفية سجلات الرحلات أو الطرود. تخضع كافة المشاوير للتدقيق المالي المحمي.'
                ], 403);
            }

            $type = $request->query('type', 'trip');

            if ($type === 'parcel') {
                $parcel = \App\Models\Parcel::findOrFail($id);
                $parcel->delete(); // Soft delete if enabled

                return response()->json([
                    'status' => 'success',
                    'message' => 'تم نقل سجل الطرد إلى الأرشيف بأمان.'
                ]);
            }

            $trip = Trip::findOrFail($id);
            $trip->delete(); // Soft delete

            return response()->json([
                'status' => 'success',
                'message' => 'تم نقل سجل المشوار إلى الأرشيف بأمان.'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'فشلت معالجة الطلب: ' . $e->getMessage()
            ], 500);
        }
    }
}