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

    public function __construct(TripService $tripService)
    {
        $this->tripService = $tripService;
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
            $trip = Trip::with(['stops', 'passenger', 'captain.user'])->find($id);
            if (!$trip) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'المشوار غير موجود.'
                ], 404);
            }
            return response()->json([
                'status' => 'success',
                'data' => new TripResource($trip)
            ]);
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
                    return app(\App\Http\Controllers\Api\ParcelController::class)->acceptParcel($request, $id);
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

        $trips = $tripQuery->take(100)->get();
        $parcels = $parcelQuery->take(100)->get();

        $tripData = TripResource::collection($trips)->resolve();

        $parcelData = $parcels->map(function ($p) {
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
                'tracking_code' => $p->tracking_code,
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
        })->toArray();

        $merged = collect($tripData)->concat($parcelData)->sortByDesc('created_at')->values();
        $total = $merged->count();
        $paginated = $merged->forPage($page, $perPage)->values();

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

        // Use DB transaction to prevent race conditions between expiration and querying
        $trips = DB::transaction(function () {
            // 1. Auto-expire pending trips older than 3 minutes that have not been accepted by any captain
            $expiredTrips = Trip::where('status', 'pending')
                ->whereNull('captain_profile_id')
                ->where('created_at', '<', now()->subMinutes(3))
                ->get();
            
            if ($expiredTrips->isNotEmpty()) {
                Trip::whereIn('id', $expiredTrips->pluck('id'))
                    ->update([
                        'status' => 'cancelled',
                        'cancellation_reason' => 'انتهت مهلة انتظار الكابتن (3 دقائق)',
                        'cancelled_at' => now(),
                    ]);
                
                foreach ($expiredTrips as $trip) {
                    $trip->status = 'cancelled';
                    try {
                        event(new \App\Events\TripStatusUpdated($trip));
                    } catch (\Exception $e) {}
                }
            }

            // 2. Query only fresh, pending, unassigned trips within the last 3 minutes
            $query = Trip::where('status', 'pending')
                ->whereNull('captain_profile_id')
                ->where('created_at', '>=', now()->subMinutes(3))
                ->with(['stops', 'passenger'])
                ->orderBy('created_at', 'desc');

            return $query->take(20)->get();
        });

        if ($lat && $lng) {
            $trips = $trips->filter(function ($trip) use ($lat, $lng) {
                if (!$trip->pickup_latitude || !$trip->pickup_longitude) return true;
                $dist = $this->calculateDistance($lat, $lng, $trip->pickup_latitude, $trip->pickup_longitude);
                return $dist <= 30.0; // within 30km radius
            })->values();
        }

        $tripData = TripResource::collection($trips)->resolve();

        // Auto-expire old pending parcels older than 3 minutes
        \App\Models\Parcel::where('status', 'pending')
            ->whereNull('captain_profile_id')
            ->where('created_at', '<', now()->subMinutes(3))
            ->update([
                'status' => 'cancelled',
                'updated_at' => now(),
            ]);

        // Also fetch fresh pending parcels within last 3 minutes
        $parcels = \App\Models\Parcel::where('status', 'pending')
            ->whereNull('captain_profile_id')
            ->where('created_at', '>=', now()->subMinutes(3))
            ->with('user')
            ->latest()
            ->take(10)
            ->get();

        $parcelData = $parcels->map(function ($p) {
            return [
                'id' => (string) $p->id,
                'status' => 'pending',
                'type' => 'delivery',
                'isParcel' => true,
                'title' => 'طلب توصيل طرد 📦',
                'description' => ($p->pickup_address ?? 'صنعاء') . ' ← ' . ($p->dropoff_address ?? 'صنعاء'),
                'price' => (float) $p->price,
                'estimated_price' => (float) $p->price,
                'final_price' => (float) $p->price,
                'grossFare' => (float) $p->price,
                'distance_km' => 2.5,
                'distance' => '2.5 كم',
                'eta' => '~6 دقائق',
                'duration' => '6 د',
                'timeTag' => $p->created_at ? $p->created_at->diffForHumans() : 'الآن',
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
                'trackingCode' => $p->tracking_code ?? ('LF-P' . $p->id),
                'tracking_code' => $p->tracking_code ?? ('LF-P' . $p->id),
                'parcelType' => $p->parcel_type ?? 'طرد',
                'parcel_type' => $p->parcel_type ?? 'طرد',
                'size' => $p->size ?? 'متوسط',
                'passengerRating' => 5.0,
                'notes' => $p->notes ?? "طرد ({$p->size})",
                'stops' => [],
            ];
        })->toArray();

        $allRequests = array_merge($tripData, $parcelData);

        return response()->json([
            'status' => 'success',
            'data'   => $allRequests
        ]);
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371; // km
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }

    public function destroy(Request $request, $id)
    {
        try {
            $user = $request->user();
            $trip = Trip::where('id', $id)
                ->where(function ($q) use ($user) {
                    $q->where('user_id', $user->id);
                    if ($user->captainProfile) {
                        $q->orWhere('captain_profile_id', $user->captainProfile->id);
                    }
                })
                ->first();

            if ($trip) {
                $trip->stops()->delete();
                $trip->delete();
                return response()->json([
                    'status' => 'success',
                    'message' => 'تم حذف الرحلة بنجاح.'
                ]);
            }

            // Check if it is a parcel
            $parcel = \App\Models\Parcel::where('id', $id)
                ->where(function ($q) use ($user) {
                    $q->where('user_id', $user->id);
                    if ($user->captainProfile) {
                        $q->orWhere('captain_profile_id', $user->captainProfile->id);
                    }
                })
                ->first();

            if ($parcel) {
                $parcel->delete();
                return response()->json([
                    'status' => 'success',
                    'message' => 'تم حذف سجل الطرد بنجاح.'
                ]);
            }

            return response()->json([
                'status' => 'error',
                'message' => 'السجل غير موجود أو غير مصرح بحذفه.'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'فشل حذف السجل: ' . $e->getMessage()
            ], 500);
        }
    }
}