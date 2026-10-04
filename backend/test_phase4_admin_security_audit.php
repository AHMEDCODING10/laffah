<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Wallet;
use App\Models\CaptainProfile;
use App\Models\Document;
use App\Services\WalletService;
use App\Services\AuthService;
use App\Livewire\Admin\DocumentsManager;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

echo "=======================================================\n";
echo "🧪 LAFFAH PLATFORM - PHASE 4 ADMIN & SECURITY AUDIT\n";
echo "=======================================================\n\n";

$errors = 0;

function assertCondition($name, $condition) {
    global $errors;
    if ($condition) {
        echo "✅ PASS: $name\n";
    } else {
        echo "❌ FAIL: $name\n";
        $errors++;
    }
}

// -----------------------------------------------------------------
// 1. Escrow Protection on Payout Requests
// -----------------------------------------------------------------
echo "--- 1. Testing Escrow Protection on Payout Requests ---\n";
$user = User::first();
if (!$user) {
    echo "⚠️ Need at least one user in DB.\n";
    exit(1);
}

$wallet = Wallet::updateOrCreate(
    ['user_id' => $user->id],
    ['balance' => 10000.0, 'held_balance' => 8000.0, 'currency' => 'YER']
);

$walletService = app(WalletService::class);

$blocked = false;
try {
    // Attempt to withdraw 3000 when only 2000 (10000 - 8000) is available
    $walletService->requestPayout($user->id, 3000.0, 'kuraimi', '123456');
} catch (\Exception $e) {
    if (str_contains($e->getMessage(), 'رصيد المحفظة المتاح غير كافٍ') || str_contains($e->getMessage(), 'معلقة')) {
        $blocked = true;
    } else {
        echo "Unexpected exception: " . $e->getMessage() . "\n";
    }
}
assertCondition("Payout exceeding available balance (held in escrow) is blocked", $blocked);

// Now attempt a valid payout within available balance (1000 YER <= 2000 available)
$allowed = false;
try {
    $res = $walletService->requestPayout($user->id, 1000.0, 'kuraimi', '123456');
    $allowed = true;
    assertCondition("Payout within available balance succeeds and balance is properly deducted", (float)$res['new_balance'] === 9000.0);
} catch (\Exception $e) {
    echo "Unexpected failure on valid payout: " . $e->getMessage() . "\n";
}
assertCondition("Valid payout succeeded", $allowed);

// Clean up test withdrawal
\App\Models\WithdrawalRequest::where('user_id', $user->id)->where('amount', 1000.0)->delete();
$wallet->balance = 10000.0;
$wallet->held_balance = 0.0;
$wallet->save();

// -----------------------------------------------------------------
// 2. OTP CSPRNG & Anti-Spam Cooldown
// -----------------------------------------------------------------
echo "\n--- 2. Testing OTP CSPRNG & Cooldown Protection ---\n";
$authService = app(AuthService::class);
$testPhone = $user->phone;

// Clear any previous cooldown for test user
$shortPhone = substr(preg_replace('/[^0-9]/', '', $testPhone), -9);
Cache::forget('otp_cooldown_' . $shortPhone);
Cache::forget('reset_code_' . $shortPhone);

$code = $authService->forgotPassword($testPhone);
assertCondition("Generated OTP is 6 digits", strlen((string)$code) === 6 && $code >= 100000 && $code <= 999999);

$cooldownBlocked = false;
try {
    // Immediately call again -> should hit 60s cooldown
    $authService->forgotPassword($testPhone);
} catch (\Exception $e) {
    if (str_contains($e->getMessage(), '60 ثانية')) {
        $cooldownBlocked = true;
    }
}
assertCondition("Repeated OTP request triggers 60s anti-spam cooldown", $cooldownBlocked);

Cache::forget('otp_cooldown_' . $shortPhone);
Cache::forget('reset_code_' . $shortPhone);

// -----------------------------------------------------------------
// 3. Strict Verification in DocumentsManager
// -----------------------------------------------------------------
echo "\n--- 3. Testing Strict Verification in DocumentsManager ---\n";
$captain = CaptainProfile::first();
if ($captain) {
    $captain->update(['is_verified' => false]);
    Document::where('captain_profile_id', $captain->id)->delete();

    // Upload only ONE document (id_card)
    $doc1 = Document::create([
        'captain_profile_id' => $captain->id,
        'type' => 'id_card',
        'file_path' => 'captain_documents/test_id.jpg',
        'status' => 'pending',
    ]);

    $docManager = new DocumentsManager();
    $docManager->approve($doc1->id);

    $captain->refresh();
    assertCondition("Captain is NOT verified with only 1 document uploaded", $captain->is_verified === false);

    // Now upload and approve vehicle registration
    $doc2 = Document::create([
        'captain_profile_id' => $captain->id,
        'type' => 'vehicle_registration',
        'file_path' => 'captain_documents/test_vehicle.jpg',
        'status' => 'pending',
    ]);

    $docManager->approve($doc2->id);
    $captain->refresh();
    assertCondition("Captain IS verified once all mandatory documents are approved", $captain->is_verified === true);
}

// -----------------------------------------------------------------
// 4. Production Deployment & Runtime Config Checks
// -----------------------------------------------------------------
echo "\n--- 4. Testing Production start.sh & CORS Config ---\n";
$startShContent = file_get_contents(__DIR__ . '/start.sh');
assertCondition("start.sh contains Laravel schedule worker", str_contains($startShContent, 'schedule:work'));
assertCondition("start.sh queue worker has memory limit bounds", str_contains($startShContent, '--memory=256'));

$corsContent = file_get_contents(__DIR__ . '/config/cors.php');
assertCondition("cors.php contains broadcasting/* in allowed paths", str_contains($corsContent, "'broadcasting/*'"));

echo "\n=======================================================\n";
if ($errors === 0) {
    echo "🎉 ALL PHASE 4 ADMIN & SECURITY AUDIT CHECKS PASSED 100%!\n";
} else {
    echo "❌ TOTAL FAILED CHECKS: $errors\n";
    exit(1);
}
echo "=======================================================\n";
