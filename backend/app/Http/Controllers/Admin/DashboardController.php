<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CaptainProfile;
use App\Models\Trip;
use App\Models\User;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            // Passengers (role=passenger) - الركاب الحقيقيون
            'total_users'      => User::whereHas('roles', fn($q) => $q->where('name', 'passenger'))->count(),
            // Captains registered (have CaptainProfile)
            'total_captains'   => CaptainProfile::count(),
            // Trips
            'completed_trips'  => Trip::where('status', 'completed')->count(),
            'active_trips'     => Trip::whereIn('status', ['accepted', 'started', 'on_the_way', 'arrived'])->count(),
            'pending_trips'    => Trip::where('status', 'pending')->count(),
            // Earnings from completed trips (final_price or estimated_price fallback)
            'total_earnings'   => Trip::where('status', 'completed')
                                    ->selectRaw('COALESCE(SUM(final_price), SUM(estimated_price), 0) as total')
                                    ->value('total') ?? 0,
            // Online captains
            'online_captains'  => \App\Models\CaptainProfile::where('is_online', true)->count(),
        ];

        $latest_trips = Trip::with(['passenger', 'captain.user'])
            ->latest()
            ->limit(8)
            ->get();

        // Chart Data (Last 7 Days)
        $chartData = [
            'labels' => [],
            'trips' => [],
            'earnings' => [],
        ];
        
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i)->format('Y-m-d');
            $chartData['labels'][] = now()->subDays($i)->locale('ar')->translatedFormat('D');
            
            $dayTrips = Trip::whereDate('created_at', $date)->count();
            $chartData['trips'][] = $dayTrips;
            
            $dayEarnings = Trip::whereDate('created_at', $date)->where('status', 'completed')->sum('final_price');
            $chartData['earnings'][] = $dayEarnings;
        }

        return view('admin.dashboard', compact('stats', 'latest_trips', 'chartData'));
    }
}
