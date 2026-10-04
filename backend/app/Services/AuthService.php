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
        $user = $this->findUserByPhone($phone);
        if (!$user) {
            throw new Exception('رقم الهاتف غير مسجل لدينا.', 404);
        }

        $shortPhone = $this->normalizePhone($phone);

        // Enforce 60-second anti-spam cooldown per phone number
        if (Cache::has('otp_cooldown_' . $shortPhone)) {
            throw new Exception('تم إرسال رمز تحقق مسبقاً. يرجى الانتظار 60 ثانية قبل طلب رمز جديد.', 429);
        }

        // Generate cryptographically secure 6-digit code (CSPRNG)
        $code = random_int(100000, 999999);
        
        // Save to cache for 10 minutes using normalized short phone
        Cache::put('reset_code_' . $shortPhone, $code, now()->addMinutes(10));
        // Reset attempt counter
        Cache::put('reset_attempts_' . $shortPhone, 0, now()->addMinutes(10));
        // Set anti-spam cooldown for 60 seconds
        Cache::put('otp_cooldown_' . $shortPhone, true, now()->addSeconds(60));

        // Format phone number for WhatsApp (always 967 + 9 digits, e.g. 967770291452)
        $waPhone = '967' . $shortPhone;

        // Send OTP via Baileys WhatsApp Microservice
        try {
            $message = "🚖 *تطبيق لَفَّة - استعادة كلمة المرور*\n\n" .
                       "رمز التحقق الخاص بك هو:\n" .
                       "🔢 *{$code}*\n\n" .
                       "⚠️ هذا الرمز صالح لمدة 10 دقائق فقط.\n" .
                       "🔒 لا تشارك هذا الرمز مع أي شخص حفاظاً على أمان حسابك.";
            
            $whatsappServerUrl = rtrim(env('WHATSAPP_SERVER_URL', 'https://laffah-whatsapp.onrender.com'), '/');
            \Illuminate\Support\Facades\Http::timeout(10)->post("{$whatsappServerUrl}/send-message", [
                'phone' => $waPhone,
                'message' => $message
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("WhatsApp OTP Delivery Failed: " . $e->getMessage());
        }

        return $code;
    }

    public function verifyResetCode(string $phone, string $code)
    {
        $shortPhone = $this->normalizePhone($phone);

        // Check attempt limit (max 5 wrong attempts)
        $attempts = (int) Cache::get('reset_attempts_' . $shortPhone, 0);
        if ($attempts >= 5) {
            Cache::forget('reset_code_' . $shortPhone);
            Cache::forget('reset_attempts_' . $shortPhone);
            throw new Exception('تم تجاوز عدد المحاولات المسموحة. أعد طلب رمز جديد.', 429);
        }

        $cachedCode = Cache::get('reset_code_' . $shortPhone);
        
        if (!$cachedCode || (string) $cachedCode !== (string) $code) {
            Cache::increment('reset_attempts_' . $shortPhone);
            throw new Exception('الرمز غير صحيح أو منتهي الصلاحية.', 400);
        }

        return true;
    }

    public function resetPassword(string $phone, string $code, string $newPassword)
    {
        $this->verifyResetCode($phone, $code);

        $user = $this->findUserByPhone($phone);
        if (!$user) {
            throw new Exception('رقم الهاتف غير مسجل لدينا.', 404);
        }

        $user->password = Hash::make($newPassword);
        $user->save();

        $shortPhone = $this->normalizePhone($phone);
        Cache::forget('reset_code_' . $shortPhone);
        Cache::forget('reset_attempts_' . $shortPhone);

        return true;
    }

    /**
     * Find user by phone supporting all Yemeni phone formats:
     * - +967770291452
     * - 967770291452
     * - 770291452
     * - 0770291452
     */
    public function findUserByPhone(string $phone): ?User
    {
        $cleanDigits = preg_replace('/[^0-9]/', '', $phone);
        $shortPhone  = substr($cleanDigits, -9);
        $withPlus    = '+967' . $shortPhone;
        $with967     = '967' . $shortPhone;

        return User::where('phone', $phone)
            ->orWhere('phone', $shortPhone)
            ->orWhere('phone', $withPlus)
            ->orWhere('phone', $with967)
            ->first();
    }

    /**
     * Normalize Yemeni phone number to standard 9 digits (e.g. 770291452)
     */
    public function normalizePhone(string $phone): string
    {
        $cleanDigits = preg_replace('/[^0-9]/', '', $phone);
        return substr($cleanDigits, -9);
    }
}