<?php

namespace App\Services;

use App\Models\User;
use App\Models\CaptainProfile;
use App\Models\Wallet;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;
use Exception;
use Illuminate\Support\Facades\DB;

class AuthService
{
    public function login(string $phone, string $password)
    {
        $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
        $shortPhone = substr($cleanPhone, -9);
        $withPrefix = '+967' . $shortPhone;

        $user = User::where('phone', $phone)
            ->orWhere('phone', $cleanPhone)
            ->orWhere('phone', $shortPhone)
            ->orWhere('phone', $withPrefix)
            ->first();

        if (!$user) {
            throw new Exception('رقم الهاتف غير مسجل لدينا.', 401);
        }

        if (!Hash::check($password, $user->password)) {
            throw new Exception('كلمة المرور غير صحيحة.', 401);
        }

        $token = JWTAuth::fromUser($user);

        return [
            'user'  => $user->load(['roles', 'captainProfile', 'wallet']),
            'token' => $token,
        ];
    }

    public function registerCaptain(array $data)
    {
        DB::beginTransaction();
        try {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'] ?? ('captain_' . time() . '_' . rand(100, 999) . '@laffah.com'),
                'phone' => $data['phone'] ?? null,
                'password' => Hash::make($data['password']),
                'email_verified_at' => now(),
            ]);

            // Ensure roles exist
            try {
                \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'captain', 'guard_name' => 'api']);
                \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'captain', 'guard_name' => 'web']);
                $user->assignRole('captain');
            } catch (\Exception $e) {
                // If spatie fails, continue safely
            }

            Wallet::firstOrCreate(['user_id' => $user->id]);

            $profile = CaptainProfile::create([
                'user_id' => $user->id,
                'vehicle_type' => $data['vehicle_type'] ?? 'دراجة نارية',
                'vehicle_model' => $data['vehicle_model'] ?? 'غير محدد',
                'plate_number' => $data['plate_number'] ?? $data['vehicle_plate'] ?? 'غير محدد',
                'vehicle_color' => $data['vehicle_color'] ?? 'أسود',
            ]);

            $token = JWTAuth::fromUser($user);
            DB::commit();

            return [
                'user' => $user->load(['roles', 'captainProfile']),
                'token' => $token,
            ];
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function registerPassenger(array $data)
    {
        DB::beginTransaction();
        try {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'] ?? ('passenger_' . time() . '_' . rand(100, 999) . '@laffah.com'),
                'phone' => $data['phone'] ?? null,
                'password' => Hash::make($data['password']),
                'email_verified_at' => now(),
            ]);

            // Ensure roles exist
            try {
                \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'passenger', 'guard_name' => 'api']);
                \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'passenger', 'guard_name' => 'web']);
                $user->assignRole('passenger');
            } catch (\Exception $e) {
                // If spatie fails, continue safely
            }

            Wallet::firstOrCreate(['user_id' => $user->id]);

            $token = JWTAuth::fromUser($user);
            DB::commit();

            return [
                'user' => $user->load(['roles', 'wallet']),
                'token' => $token,
            ];
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function forgotPassword(string $phone)
    {
        $user = User::where('phone', $phone)->first();
        if (!$user) {
            throw new Exception('رقم الهاتف غير مسجل لدينا.', 404);
        }

        // Generate 6-digit code
        $code = rand(100000, 999999);
        
        // Save to cache for 10 minutes
        Cache::put('reset_code_' . $phone, $code, now()->addMinutes(10));
        // Reset attempt counter
        Cache::put('reset_attempts_' . $phone, 0, now()->addMinutes(10));

        // Format phone number for WhatsApp (must include country code without '+')
        $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
        if (strlen($cleanPhone) == 9) {
            $cleanPhone = '967' . $cleanPhone;
        }

        // Send OTP via Local Baileys Node.js Microservice
        try {
            $message = "أهلاً بك في تطبيق لَفّة 🚕!\nرمز التحقق الخاص بك هو: *$code*\nلا تشارك هذا الرمز مع أحد.";
            
            $whatsappServerUrl = env('WHATSAPP_SERVER_URL', 'http://localhost:3000');
            \Illuminate\Support\Facades\Http::post("{$whatsappServerUrl}/send-message", [
                'phone' => $cleanPhone,
                'message' => $message
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Local WhatsApp OTP Failed: " . $e->getMessage());
        }

        return $code;
    }

    public function verifyResetCode(string $phone, string $code)
    {
        // Check attempt limit (max 5 wrong attempts)
        $attempts = (int) Cache::get('reset_attempts_' . $phone, 0);
        if ($attempts >= 5) {
            Cache::forget('reset_code_' . $phone);
            Cache::forget('reset_attempts_' . $phone);
            throw new Exception('تم تجاوز عدد المحاولات المسموحة. أعد طلب رمز جديد.', 429);
        }

        $cachedCode = Cache::get('reset_code_' . $phone);
        
        if (!$cachedCode || (string) $cachedCode !== (string) $code) {
            Cache::increment('reset_attempts_' . $phone);
            throw new Exception('الرمز غير صحيح أو منتهي الصلاحية.', 400);
        }

        return true;
    }

    public function resetPassword(string $phone, string $code, string $newPassword)
    {
        $this->verifyResetCode($phone, $code);

        $user = User::where('phone', $phone)->first();
        if (!$user) {
            throw new Exception('رقم الهاتف غير مسجل لدينا.', 404);
        }

        $user->password = Hash::make($newPassword);
        $user->save();

        Cache::forget('reset_code_' . $phone);

        return true;
    }
}