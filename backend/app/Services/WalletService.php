<?php

namespace App\Services;

use App\Models\Wallet;
use App\Models\Transaction;
use App\Models\Trip;
use App\Models\CaptainProfile;
use App\Models\WithdrawalRequest;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Exception;

class WalletService
{
    const YEMENI_CHANNELS = [
        'kuraimi'  => 'الكريمي (M-Floos / حاسب)',
        'tadhamon' => 'محفظتي (بنك التضامن)',
        'jeeb'     => 'محفظة جيب (مصرف اليمن والبحرين الشامل)',
        'cac'      => 'كاك بنك / السريع',
        'onecash'  => 'ون كاش (OneCash)',
        'jawali'   => 'جوالي (WeCash)',
        'floosak'  => 'فلوسك (Floosak)',
        'cash'     => 'نقداً / إيداع مباشر',
    ];

    /**
     * Get official company receiving accounts for Yemeni wallets.
     */
    public function getCompanyAccounts(): array
    {
        return [
            ['id' => 'onecash',  'name' => 'ون كاش (OneCash)',                    'account_number' => '777000111', 'account_name' => 'منصة لَفَّة للنقل الذكي',          'instructions' => 'قم بالتحويل عبر تطبيق OneCash إلى رقم الحساب أعلاه ثم انسخ رقم العملية.', 'app_scheme' => 'onecash://',  'icon' => 'phone_android',           'badge' => 'فوري وسريع'],
            ['id' => 'kuraimi',  'name' => 'الكريمي إكسبرس (حاسب / M-Floos)',     'account_number' => '3001234567','account_name' => 'مؤسسة لَفَّة للخدمات اللوجستية', 'instructions' => 'حول عبر تطبيق الكريمي جوال (حاسب أو إم فلوس) وضع رقم العملية هنا.',    'app_scheme' => 'kuraimi://', 'icon' => 'account_balance',         'badge' => 'شائع جداً'],
            ['id' => 'jawali',   'name' => 'جوالي (WeCash)',                       'account_number' => '770123456', 'account_name' => 'منصة لَفَّة - صنعاء',              'instructions' => 'قم بإرسال الحوالة عبر محفظة جوالي ثم اكتب رقم إشعار التحويل.',          'app_scheme' => 'wecash://',  'icon' => 'wallet',                  'badge' => 'فوري'],
            ['id' => 'jeeb',     'name' => 'محفظة جيب (مصرف اليمن والبحرين)',     'account_number' => '500987654', 'account_name' => 'شركة لَفَّة المحدودة',              'instructions' => 'حول من محفظة جيب إلى رقم الحساب ثم انسخ الرقم المرجعي للعملية.',        'app_scheme' => 'jeeb://',    'icon' => 'card_giftcard',           'badge' => 'فوري'],
            ['id' => 'tadhamon', 'name' => 'محفظتي (بنك التضامن)',                 'account_number' => '880112233', 'account_name' => 'لَفَّة لخدمات التوصيل',            'instructions' => 'حول عبر تطبيق محفظتي وضع رقم إشعار الدفع لتأكيد العملية.',              'app_scheme' => 'tadhamon://', 'icon' => 'account_balance_wallet', 'badge' => 'فوري'],
            ['id' => 'cac',      'name' => 'كاك بنك (السريع / موبايل موني)',       'account_number' => '100456789', 'account_name' => 'لَفَّة للنقل والتوصيل',             'instructions' => 'حول عبر كاك بنك أو موبايل موني وضع رقم المعاملة.',                      'app_scheme' => 'cacbank://', 'icon' => 'account_balance',         'badge' => 'فوري'],
        ];
    }

    /**
     * Get wallet balance + statistics (supports both snake_case and camelCase for mobile app compatibility).
     */
    public function getBalance($userId)
    {
        $wallet = Wallet::firstOrCreate(
            ['user_id' => $userId],
            ['balance' => 0.0, 'currency' => 'YER']
        );
        $transactions = $wallet->transactions()->orderBy('created_at', 'desc')->take(20)->get();
        $captainProfile = CaptainProfile::where('user_id', $userId)->first();

        $todayEarnings = 0;
        $weeklyEarnings = 0;
        $previousWeekEarnings = 0;
        $completedTripsToday = 0;

        if ($captainProfile) {
            $today = Carbon::today();
            $startOfWeek = Carbon::now()->startOfWeek();
            $startOfPreviousWeek = Carbon::now()->subWeek()->startOfWeek();
            $endOfPreviousWeek   = Carbon::now()->subWeek()->endOfWeek();

            $todayTrips = Trip::where('captain_profile_id', $captainProfile->id)
                ->where('status', 'completed')->whereDate('created_at', $today)->get();
            $completedTripsToday = $todayTrips->count();
            $todayEarnings = (double) $todayTrips->sum('captain_earnings');

            $weeklyEarnings = (double) Trip::where('captain_profile_id', $captainProfile->id)
                ->where('status', 'completed')->whereBetween('created_at', [$startOfWeek, Carbon::now()])->sum('captain_earnings');

            $previousWeekEarnings = (double) Trip::where('captain_profile_id', $captainProfile->id)
                ->where('status', 'completed')->whereBetween('created_at', [$startOfPreviousWeek, $endOfPreviousWeek])->sum('captain_earnings');
        }

        $formattedTransactions = $transactions->map(function ($tx) {
            $isNegative = in_array($tx->type, ['withdrawal', 'commission', 'deduction']);
            return [
                'id'           => (string) $tx->id,
                'type'         => $tx->type,
                'title'        => $tx->description ?? 'معاملة مالية',
                'amount'       => (double) $tx->amount,
                'description'  => $tx->description,
                'reference_id' => $tx->reference_id,
                'refId'        => $tx->reference_id ?? '',
                'date'         => $tx->created_at->format('Y-m-d H:i:s'),
                'status'       => 'مكتمل',
                'isNegative'   => $isNegative,
            ];
        });

        return [
            'balance'                 => (double) $wallet->balance,
            'availableBalance'        => (double) $wallet->balance,
            'currency'                => $wallet->currency ?? 'YER',
            'today_earnings'          => (double) $todayEarnings,
            'todayEarnings'           => (double) $todayEarnings,
            'weekly_earnings'         => (double) $weeklyEarnings,
            'weeklyEarnings'          => (double) $weeklyEarnings,
            'previous_week_earnings'  => (double) $previousWeekEarnings,
            'previousWeekEarnings'    => (double) $previousWeekEarnings,
            'completed_trips_today'   => $completedTripsToday,
            'completedTripsToday'     => $completedTripsToday,
            'daily_target'            => 5000.0,
            'dailyTarget'             => 5000.0,
            'company_accounts'        => $this->getCompanyAccounts(),
            'companyAccounts'         => $this->getCompanyAccounts(),
            'recent_transactions'     => $formattedTransactions,
            'recentTransactions'      => $formattedTransactions,
            'transactions'            => $formattedTransactions,
        ];
    }

    /**
     * Instant Wallet Recharge via Yemeni Payment Channels.
     */
    public function recharge($userId, float $amount, string $referenceId, string $paymentMethod = 'cash', ?string $senderAccount = null)
    {
        $cleanRef = trim($referenceId);
        if (empty($cleanRef)) {
            throw new Exception('رقم الحوالة أو المرجع مطلوب.', 422);
        }

        if ($amount < 500) {
            throw new Exception('الحد الأدنى للشحن هو 500 ريال يمني.', 422);
        }
        if ($amount > 100000) {
            throw new Exception('الحد الأقصى للشحن في العملية الواحدة هو 100,000 ريال يمني.', 422);
        }

        $methodName = self::YEMENI_CHANNELS[$paymentMethod] ?? $paymentMethod;
        $senderInfo = $senderAccount ? " (من حساب: $senderAccount)" : '';
        $desc = "شحن رصيد فوري عبر $methodName - رقم السند: $cleanRef$senderInfo";

        try {
            return DB::transaction(function () use ($userId, $amount, $cleanRef, $desc) {
                $existing = Transaction::where('reference_id', $cleanRef)->lockForUpdate()->first();
                if ($existing) {
                    throw new Exception('رقم الحوالة أو المرجع هذا تم استخدامه مسبقاً! لا يمكن تكرار عملية الشحن.', 409);
                }

                $wallet = Wallet::firstOrCreate(['user_id' => $userId], ['balance' => 0.0, 'currency' => 'YER']);
                $wallet = Wallet::where('id', $wallet->id)->lockForUpdate()->first();
                $wallet->balance += $amount;
                $wallet->save();

                $transaction = Transaction::create([
                    'wallet_id'    => $wallet->id,
                    'type'         => 'deposit',
                    'amount'       => $amount,
                    'description'  => $desc,
                    'reference_id' => $cleanRef,
                ]);

                return ['wallet' => $wallet, 'transaction' => $transaction, 'new_balance' => (double) $wallet->balance];
            });
        } catch (\Illuminate\Database\QueryException $qe) {
            if (str_contains($qe->getMessage(), 'UNIQUE') || str_contains($qe->getMessage(), 'Duplicate') || $qe->getCode() == 23000) {
                throw new Exception('رقم الحوالة أو المرجع هذا تم استخدامه مسبقاً! لا يمكن تكرار عملية الشحن.', 409);
            }
            throw $qe;
        }
    }

    /**
     * Request payout (withdrawal) via Yemeni Payment Channels.
     * Deducts balance immediately and creates a WithdrawalRequest record (status: pending).
     * The balance is returned automatically if admin rejects the request.
     */
    public function requestPayout($userId, float $amount, string $payoutMethod, ?string $accountNumber = null, ?string $accountName = null)
    {
        if ($amount <= 0) {
            throw new Exception('المبلغ يجب أن يكون أكبر من الصفر.', 422);
        }
        if ($amount < 500) {
            throw new Exception('الحد الأدنى للسحب هو 500 ريال يمني.', 422);
        }

        $methodName = self::YEMENI_CHANNELS[$payoutMethod] ?? $payoutMethod;
        $accInfo = $accountNumber ? " (حساب: $accountNumber)" : '';
        $desc = "طلب سحب رصيد عبر $methodName$accInfo";

        return DB::transaction(function () use ($userId, $amount, $payoutMethod, $accountNumber, $accountName, $desc) {
            $wallet = Wallet::where('user_id', $userId)->lockForUpdate()->first();

            if (!$wallet || $wallet->balance <= 0) {
                throw new Exception('لا يمكن طلب السحب ورصيدك صفر أو سالب. يرجى شحن الرصيد أولاً.', 422);
            }

            if ($wallet->balance < $amount) {
                throw new Exception('رصيد المحفظة غير كافٍ لإتمام عملية السحب.', 422);
            }

            // 1. Deduct balance immediately (locked/reserved)
            $wallet->balance -= $amount;
            $wallet->save();

            // 2. Generate unique reference ID
            $refId = 'WD-' . strtoupper(bin2hex(random_bytes(4)));

            // 3. Log withdrawal transaction
            Transaction::create([
                'wallet_id'    => $wallet->id,
                'type'         => 'withdrawal',
                'amount'       => $amount,
                'description'  => $desc,
                'reference_id' => $refId,
            ]);

            // 4. Create WithdrawalRequest record for Admin Dashboard
            $captainProfile = CaptainProfile::where('user_id', $userId)->first();
            $withdrawalRequest = WithdrawalRequest::create([
                'captain_profile_id' => $captainProfile ? $captainProfile->id : null,
                'user_id'            => $userId,
                'amount'             => $amount,
                'payment_method'     => $payoutMethod,
                'account_number'     => $accountNumber,
                'account_name'       => $accountName,
                'status'             => 'pending',
                'notes'              => "طلب سحب عبر $desc",
            ]);

            return [
                'wallet'             => $wallet,
                'withdrawal_request' => $withdrawalRequest,
                'new_balance'        => (double) $wallet->balance,
            ];
        });
    }

    /**
     * Admin completes the payout after sending money to captain.
     */
    public function completePayout(int $withdrawalRequestId, ?int $adminId = null, ?string $transferReference = null): WithdrawalRequest
    {
        return DB::transaction(function () use ($withdrawalRequestId, $adminId, $transferReference) {
            $req = WithdrawalRequest::where('id', $withdrawalRequestId)->lockForUpdate()->firstOrFail();

            if ($req->status !== 'pending') {
                throw new Exception("لا يمكن تنفيذ هذا الطلب لأنه بحالة: {$req->status}", 422);
            }

            $req->update([
                'status'             => 'completed',
                'processed_by'       => $adminId,
                'processed_at'       => now(),
                'transfer_reference' => $transferReference,
            ]);

            return $req;
        });
    }

    /**
     * Admin rejects payout — refunds the reserved amount back to captain's wallet automatically.
     */
    public function rejectPayout(int $withdrawalRequestId, ?int $adminId = null, ?string $rejectionReason = null): WithdrawalRequest
    {
        return DB::transaction(function () use ($withdrawalRequestId, $adminId, $rejectionReason) {
            $req = WithdrawalRequest::where('id', $withdrawalRequestId)->lockForUpdate()->firstOrFail();

            if ($req->status !== 'pending') {
                throw new Exception("لا يمكن رفض هذا الطلب لأنه بحالة: {$req->status}", 422);
            }

            $userId = $req->user_id ?? ($req->captainProfile ? $req->captainProfile->user_id : null);
            if (!$userId) {
                throw new Exception('لم يتم العثور على صاحب الطلب لإعادة الرصيد إليه.', 404);
            }

            // 1. Refund the balance back to user's wallet
            $wallet = Wallet::where('user_id', $userId)->lockForUpdate()->firstOrFail();
            $wallet->balance += $req->amount;
            $wallet->save();

            // 2. Log the refund transaction
            Transaction::create([
                'wallet_id'    => $wallet->id,
                'type'         => 'deposit',
                'amount'       => $req->amount,
                'description'  => "استرجاع مبلغ سحب مرفوض #{$req->id}" . ($rejectionReason ? " (السبب: $rejectionReason)" : ''),
                'reference_id' => 'REFUND-' . $req->id . '-' . strtoupper(bin2hex(random_bytes(2))),
            ]);

            // 3. Mark request as rejected
            $req->update([
                'status'           => 'rejected',
                'processed_by'     => $adminId,
                'processed_at'     => now(),
                'rejection_reason' => $rejectionReason,
            ]);

            return $req;
        });
    }
}