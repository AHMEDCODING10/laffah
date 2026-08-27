<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class HealthController extends Controller
{
    /**
     * Health check endpoint for cloud monitoring, load balancers, and uptime monitors.
     */
    public function check(): JsonResponse
    {
        $status = 'healthy';
        $services = [];
        $httpCode = 200;

        // 1. Database Connection Check
        try {
            DB::connection()->getPdo();
            $services['database'] = [
                'status' => 'connected',
                'driver' => DB::connection()->getDriverName(),
            ];
        } catch (\Exception $e) {
            $status = 'unhealthy';
            $httpCode = 503;
            $services['database'] = [
                'status' => 'error',
                'message' => $e->getMessage(),
            ];
        }

        // 2. Cache Store Check
        try {
            Cache::put('health_check_ping', 'pong', 5);
            $cachePing = Cache::get('health_check_ping');
            $services['cache'] = [
                'status' => $cachePing === 'pong' ? 'operational' : 'degraded',
                'driver' => config('cache.default'),
            ];
        } catch (\Exception $e) {
            $services['cache'] = [
                'status' => 'degraded',
                'message' => $e->getMessage(),
            ];
        }

        return response()->json([
            'status'      => $status,
            'app_name'    => config('app.name', 'Laffah'),
            'environment' => config('app.env'),
            'timestamp'   => now()->toISOString(),
            'php_version' => PHP_VERSION,
            'services'    => $services,
        ], $httpCode);
    }
}
