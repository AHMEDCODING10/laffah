<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

/**
 * Class TrackingController
 * @deprecated Use CaptainController::updateLocation via POST /api/captain/update-location
 */
class TrackingController extends Controller
{
    public function updateLocation(Request $request, $captainId = null)
    {
        return response()->json([
            'status' => 'error',
            'message' => 'This endpoint has been deprecated and disabled for security reasons. Please use POST /api/captain/update-location with Bearer authentication.'
        ], 410);
    }
}