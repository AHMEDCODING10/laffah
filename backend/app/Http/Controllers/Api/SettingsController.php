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
                'app_name'               => $settings['app_name'] ?? 'لَفَّة',
                'support_phone'          => $settings['support_phone'] ?? '770291452',
                'support_email'          => $settings['support_email'] ?? 'support@laffah.com',
                'terms_and_conditions'   => $settings['terms_and_conditions'] ?? '',
                'privacy_policy'         => $settings['privacy_policy'] ?? '',
                'pricing' => [
                    'price_per_km'          => (float) ($settings['price_per_km'] ?? 175),
                    'multi_stop_fee'        => (float) ($settings['multi_stop_fee'] ?? 300),
                    'commission_percent'    => (float) ($settings['commission_percent'] ?? 15),
                    'parcel_percent_small'  => (float) ($settings['parcel_percent_small'] ?? 10),
                    'parcel_percent_medium' => (float) ($settings['parcel_percent_medium'] ?? 15),
                    'parcel_percent_large'  => (float) ($settings['parcel_percent_large'] ?? 20),
                ],
                'operational' => [
                    'search_radius_km'      => (float) ($settings['search_radius_km'] ?? 10),
                    'min_withdrawal_amount' => (float) ($settings['min_withdrawal_amount'] ?? 1000),
                ],
            ]
        ]);
    }
}
