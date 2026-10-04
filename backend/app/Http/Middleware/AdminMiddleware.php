<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!auth()->check()) {
            return redirect()->route('admin.login');
        }

        if (!auth()->user()->hasRole('admin')) {
            abort(403, 'غير مصرح لك بالدخول.');
        }

        if (isset(auth()->user()->is_active) && !auth()->user()->is_active) {
            auth()->logout();
            abort(403, 'تم تعطيل هذا الحساب الإداري. يرجى التواصل مع الإدارة العليا.');
        }

        return $next($request);
    }
}
