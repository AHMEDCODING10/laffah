<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\PaymentGateways\PaymentGatewayManager;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Events\WalletBalanceUpdated;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PaymentWebhookController extends Controller
{
    protected PaymentGatewayManager $gatewayManager;

    public function __construct(PaymentGatewayManager $gatewayManager)
    {
        $this->gatewayManager = $gatewayManager;
    }

    /**
     * Unified Webhook Receiver for Yemeni Payment Gateways.
     */
    public function handle(string $gateway, Request $request)
    {
        Log::info("[PaymentWebhook] Received notification for gateway: {$gateway}", [
            'payload' => $request->all(),
            'headers' => $request->headers->all(),
        ]);

        try {
            $driver = $this->gatewayManager->driver($gateway);
            $result = $driver->handleWebhook($request->all(), $request->headers->all());

            if (!($result['verified'] ?? false)) {
                Log::warning("[PaymentWebhook] Signature verification failed for {$gateway}");
                return response()->json(['status' => 'error', 'message' => 'Invalid signature'], 403);
            }

            $referenceId = $result['reference_id'] ?? null;
            if (!$referenceId) {
                return response()->json(['status' => 'error', 'message' => 'Missing reference ID'], 400);
            }

            // Lock and process transaction idempotently
            return DB::transaction(function () use ($referenceId, $result, $gateway) {
                $transaction = Transaction::where('reference_id', $referenceId)
                    ->lockForUpdate()
                    ->first();

                if (!$transaction) {
                    Log::warning("[PaymentWebhook] Transaction reference {$referenceId} not found in database.");
                    return response()->json(['status' => 'ignored', 'message' => 'Transaction not found'], 200);
                }

                if ($transaction->status === 'completed') {
                    // Already processed (Idempotent response)
                    return response()->json(['status' => 'success', 'message' => 'Already processed'], 200);
                }

                if ($result['status'] === 'completed') {
                    $wallet = Wallet::where('id', $transaction->wallet_id)
                        ->lockForUpdate()
                        ->firstOrFail();

                    $wallet->balance += $transaction->amount;
                    $wallet->save();

                    $transaction->update([
                        'status'      => 'completed',
                        'description' => str_replace(' - قيد المراجعة', ' - معتمد آلياً عبر بوابة ' . ucfirst($gateway), $transaction->description),
                        'approved_at' => now(),
                    ]);

                    // Real-time broadcast to mobile app
                    try {
                        event(new WalletBalanceUpdated(
                            $wallet,
                            $transaction,
                            "تم إيداع مبلغ " . number_format($transaction->amount, 0) . " ر.ي في محفظتك بنجاح عبر {$gateway}"
                        ));
                    } catch (\Exception $e) {}

                    Log::info("[PaymentWebhook] Successfully auto-credited transaction #{$transaction->id} for user {$wallet->user_id}");
                } elseif ($result['status'] === 'failed') {
                    $transaction->update([
                        'status'      => 'rejected',
                        'admin_notes' => 'فشلت العملية من جهة البنك/المحفظة',
                        'rejected_at' => now(),
                    ]);
                }

                return response()->json(['status' => 'success'], 200);
            });
        } catch (\Exception $e) {
            Log::error("[PaymentWebhook] Exception processing webhook: " . $e->getMessage());
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}
