<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\WalletService;
use App\Http\Requests\Wallet\RechargeRequest;
use App\Http\Requests\Wallet\PayoutRequest;

class WalletController extends Controller
{
    protected $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function balance(Request $request)
    {
        try {
            $data = $this->walletService->getBalance($request->user()->id);
            return response()->json(['status' => 'success', 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function companyAccounts(Request $request)
    {
        try {
            $accounts = $this->walletService->getCompanyAccounts();
            return response()->json(['status' => 'success', 'data' => $accounts]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function recharge(RechargeRequest $request)
    {
        try {
            $result = $this->walletService->recharge(
                $request->user()->id,
                (float) $request->amount,
                $request->reference_id,
                $request->payment_method,
                $request->sender_account
            );
            return response()->json([
                'status'  => 'success',
                'message' => 'تم شحن رصيد المحفظة بنجاح!',
                'data'    => [
                    'wallet'      => $result['wallet'],
                    'transaction' => $result['transaction'],
                    'new_balance' => $result['new_balance'],
                ],
            ]);
        } catch (\Exception $e) {
            $code = ($e->getCode() >= 400 && $e->getCode() < 600) ? $e->getCode() : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $code);
        }
    }

    /**
     * Captain requests a payout to their Yemeni e-wallet.
     * Balance is deducted immediately and a WithdrawalRequest record is created for admin approval.
     */
    public function payoutRequest(Request $request)
    {
        try {
            // Accept both 'payout_method' (from WalletController) and 'method' (from CaptainBloc)
            $payoutMethod  = $request->input('payout_method') ?? $request->input('payment_method') ?? $request->input('method');
            $accountNumber = $request->input('account_number');
            $accountName   = $request->input('account_name');
            $amount        = (float) $request->input('amount');

            if ($amount <= 0) {
                return response()->json(['status' => 'error', 'message' => 'يرجى إدخال مبلغ السحب.'], 422);
            }
            if (!$payoutMethod) {
                return response()->json(['status' => 'error', 'message' => 'يرجى تحديد وسيلة الدفع أو المحفظة الإلكترونية.'], 422);
            }

            $result = $this->walletService->requestPayout(
                $request->user()->id,
                $amount,
                $payoutMethod,
                $accountNumber,
                $accountName
            );

            return response()->json([
                'status'  => 'success',
                'message' => 'تم تقديم طلب سحب الرصيد بنجاح. سيتم تحويله إلى محفظتك خلال وقت قصير.',
                'data'    => [
                    'wallet'             => $result['wallet'],
                    'withdrawal_request' => $result['withdrawal_request'],
                    'new_balance'        => $result['new_balance'],
                ],
            ]);
        } catch (\Exception $e) {
            $code = ($e->getCode() >= 400 && $e->getCode() < 600) ? $e->getCode() : 400;
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], $code);
        }
    }
}