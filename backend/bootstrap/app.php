<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        channels: __DIR__.'/../routes/channels.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->trustProxies(at: '*');

        $middleware->api(prepend: [
            \App\Http\Middleware\SetLocale::class,
        ]);
        
        $middleware->alias([
            'admin' => \App\Http\Middleware\AdminMiddleware::class,
        ]);
        // [API ARCHITECTURE FIX ISSUE-2.7]: Never redirect API or broadcasting requests to HTML login page!
        $middleware->redirectGuestsTo(fn (\Illuminate\Http\Request $request) => ($request->is('api/*') || $request->is('broadcasting/*') || $request->expectsJson()) ? null : route('admin.login'));
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e, \Illuminate\Http\Request $request) {
            if ($request->is('api/*') || $request->is('broadcasting/*') || $request->expectsJson()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'انتهت صلاحية الجلسة أو غير مصرح بالدخول.',
                ], 401);
            }
        });
    })->create();

