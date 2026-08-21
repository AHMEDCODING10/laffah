<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SavedPlace;

class SavedPlaceController extends Controller
{
    public function index(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => $request->user()->savedPlaces
        ]);
    }

    public function store(Request $request)
    {
        $lat = $request->lat ?? $request->latitude;
        $lng = $request->lng ?? $request->longitude;
        $request->merge(['lat' => $lat, 'lng' => $lng]);

        $request->validate([
            'name' => 'required|string',
            'address' => 'required|string',
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'type' => 'nullable|string',
        ]);

        $place = $request->user()->savedPlaces()->create($request->all());

        return response()->json([
            'status' => 'success',
            'message' => __('messages.msg_15'),
            'data' => $place
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $place = $request->user()->savedPlaces()->where('id', $id)->first();

        if (!$place) {
            return response()->json([
                'status' => 'error',
                'message' => __('messages.msg_16')
            ], 404);
        }

        $place->delete();

        return response()->json([
            'status' => 'success',
            'message' => __('messages.msg_17')
        ]);
    }
}
