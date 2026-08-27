<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function index()
    {

        // Fetch settings and map to key-value array
        $settings = Setting::all()->pluck('value', 'key')->toArray();

        return response()->json([
            'status' => 'success',
            'data' => [
                'app_name' => $settings['app_name'] ?? 'Laffah',
                'support_phone' => $settings['support_phone'] ?? '770291452',
                'support_email' => $settings['support_email'] ?? '',
                'terms_and_conditions' => $settings['terms_and_conditions'] ?? '',
                'privacy_policy' => $settings['privacy_policy'] ?? '',
            ]
        ]);
    }
}
