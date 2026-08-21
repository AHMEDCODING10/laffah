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
        $statusFilter = $request->query('status_filter') ?? $request->query('status');
        $perPage = (int) ($request->query('per_page', 20));

        $query = Trip::with(['stops', 'passenger', 'captain.user'])->orderBy('created_at', 'desc');

        if ($user->hasRole('captain') && $user->captainProfile) {
            $query->where('captain_profile_id', $user->captainProfile->id);
        } else {
            $query->where('user_id', $user->id);
        }

        if ($statusFilter && $statusFilter !== 'all') {
            $query->where('status', $statusFilter);
        }

        $trips = $query->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data'   => TripResource::collection($trips->items()),
            'pagination' => [
                'current_page' => $trips->currentPage(),
                'last_page'    => $trips->lastPage(),
                'per_page'     => $trips->perPage(),
                'total'        => $trips->total(),
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
            $radius = \App\Services\TripService::getSearchRadiusKm();
            $trips = $trips->filter(function ($trip) use ($lat, $lng, $radius) {
                if (!$trip->pickup_latitude || !$trip->pickup_longitude) return true;
                $dist = $this->calculateDistance($lat, $lng, $trip->pickup_latitude, $trip->pickup_longitude);
                return $dist <= $radius;
            })->values();
        }

        return response()->json([
            'status' => 'success',
            'data'   => TripResource::collection($trips)
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
}