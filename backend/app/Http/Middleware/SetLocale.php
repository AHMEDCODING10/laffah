<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SetLocale
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $lang = $request->header('Accept-Language');
        
        if ($lang && in_array($lang, ['en', 'ar'])) {
            app()->setLocale($lang);
        } else {
            app()->setLocale('ar'); // Default to Arabic
        }

        return $next($request);
    }
}
