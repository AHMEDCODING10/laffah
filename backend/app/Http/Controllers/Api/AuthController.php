<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterCaptainRequest;
use App\Http\Requests\Auth\RegisterPassengerRequest;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    public function login(LoginRequest $request)
    {
        try {
            $result = $this->authService->login($request->phone, $request->password);
            return response()->json([
                'status'  => 'success',
                'message' => __('messages.msg_1') ?: 'تم تسجيل الدخول بنجاح.',
                'data'    => $result
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 401);
        }
    }

    public function registerCaptain(RegisterCaptainRequest $request)
    {
        try {
            $result = $this->authService->registerCaptain($request->validated());
            return response()->json([
                'status' => 'success',
                'message' => __('messages.msg_2') ?: 'تم تسجيل الكابتن بنجاح.',
                'data' => $result
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function registerPassenger(RegisterPassengerRequest $request)
    {
        try {
            $result = $this->authService->registerPassenger($request->validated());
            return response()->json([
                'status' => 'success',
                'message' => __('messages.msg_3') ?: 'تم تسجيل الراكب بنجاح.',
                'data' => $result
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function profile(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => $request->user()->load(['roles', 'captainProfile', 'wallet'])
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        
        $request->validate([
            'name' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:20|unique:users,phone,' . $user->id,
            'email' => 'nullable|email|unique:users,email,' . $user->id,
            'fcm_token' => 'nullable|string',
            'app_language' => 'nullable|string|in:ar,en',
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg|max:5120',
        ]);

        $data = $request->only(['name', 'phone', 'email', 'fcm_token', 'app_language']);
        $data = array_filter($data, fn($value) => !is_null($value) && $value !== '');

        if ($request->hasFile('avatar')) {
            $path = $request->file('avatar')->store('avatars', 'public');
            $data['avatar'] = asset('storage/' . $path);
        }

        if (!empty($data)) {
            $user->update($data);
        }

        return response()->json([
            'status' => 'success',
            'success' => true,
            'message' => __('messages.msg_4') ?: 'تم تحديث الملف الشخصي بنجاح.',
            'data' => $user->load(['roles', 'captainProfile', 'wallet'])
        ]);
    }

    public function deleteAccount(Request $request)
    {
        $user = $request->user();

        // 1. Verify if captain has negative balance
        if ($user->hasRole('captain') && $user->wallet) {
            if ($user->wallet->balance < 0) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'لا يمكنك حذف حسابك لأن لديك رصيد سالب (مديونية) قدره ' . number_format($user->wallet->balance) . ' ريال. يرجى تصفية الحساب أولاً.'
                ], 403);
            }
        }

        try {
            // Revoke current token
            if (method_exists(auth(), 'logout')) {
                auth()->logout();
            } else {
                $user->currentAccessToken()->delete();
            }

            // Perform deletion (Soft delete or hard delete depending on User model config)
            $user->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'تم حذف الحساب بنجاح.'
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function logout(Request $request)
    {
        try {
            // Revoke current token
            if (method_exists(auth(), 'logout')) {
                auth()->logout();
            } else {
                $request->user()->currentAccessToken()->delete();
            }

            return response()->json([
                'status' => 'success',
                'message' => __('messages.msg_5') ?: 'تم تسجيل الخروج بنجاح.'
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['phone' => 'required|string']);
        
        try {
            $code = $this->authService->forgotPassword($request->phone);
            Log::info("Password reset OTP generated for phone {$request->phone}");
            return response()->json([
                'status' => 'success',
                'message' => __('messages.msg_6') ?: 'تم إرسال رمز استعادة كلمة المرور بنجاح.',
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode() == 404 ? 404 : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $code);
        }
    }

    public function verifyResetCode(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'code' => 'required|string'
        ]);

        try {
            $this->authService->verifyResetCode($request->phone, $request->code);
            return response()->json([
                'status' => 'success',
                'message' => __('messages.msg_7') ?: 'تم التحقق من الرمز بنجاح.'
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'code' => 'required|string',
            'password' => 'required|string|min:6'
        ]);

        try {
            $this->authService->resetPassword($request->phone, $request->code, $request->password);
            return response()->json([
                'status' => 'success',
                'message' => __('messages.msg_8') ?: 'تم تغيير كلمة المرور بنجاح.'
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }
}