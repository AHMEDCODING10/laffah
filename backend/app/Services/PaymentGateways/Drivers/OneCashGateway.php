<?php

namespace App\Services\PaymentGateways\Drivers;

use App\Services\PaymentGateways\PaymentGatewayInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class OneCashGateway implements PaymentGatewayInterface
{
    protected string $merchantId;
    protected string $terminalId;
    protected string $secretKey;
    protected string $baseUrl;

    public function __construct()
    {
        $this->merchantId = env('ONECASH_MERCHANT_ID', '');
        $this->terminalId = env('ONECASH_TERMINAL_ID', '');
        $this->secretKey  = env('ONECASH_SECRET_KEY', '');
        $this->baseUrl    = env('ONECASH_BASE_URL', 'https://api.onecash.ye/v1');
    }

    public function getIdentifier(): string
    {
        return 'onecash';
    }

    public function isConfigured(): bool
    {
        return !empty($this->merchantId) && !empty($this->secretKey);
    }

    public function initiatePayment(array $data): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'status'  => 'unconfigured',
                'message' => 'بوابة ون كاش (OneCash) بانتظار إدخال مفاتيح الربط التجاري في ملف .env.',
                'guide'   => 'يتطلب الربط: ONECASH_MERCHANT_ID, ONECASH_TERMINAL_ID, ONECASH_SECRET_KEY',
            ];
        }

        try {
            $timestamp = time();
            $signature = hash_hmac('sha256', $this->merchantId . $data['reference_id'] . $data['amount'] . $timestamp, $this->secretKey);

            $response = Http::timeout(15)
                ->withHeaders([
                    'X-Merchant-ID' => $this->merchantId,
                    'X-Terminal-ID' => $this->terminalId,
                    'X-Signature'   => $signature,
                    'X-Timestamp'   => (string) $timestamp,
                ])
                ->post("{$this->baseUrl}/merchant/checkout/initiate", [
                    'reference'      => $data['reference_id'],
                    'customer_phone' => $data['phone'] ?? $data['sender_account'] ?? '',
                    'amount'         => $data['amount'],
                    'currency'       => 'YER',
                    'callback_url'   => url('/api/v1/payments/onecash/webhook'),
                    'description'    => $data['description'] ?? 'شحن رصيد منصة لَفَّة',
                ]);

            if ($response->successful()) {
                $body = $response->json();
                return [
                    'success'        => true,
                    'status'         => 'pending_otp',
                    'transaction_id' => $body['data']['onecash_trans_id'] ?? $data['reference_id'],
                    'mode'           => 'otp',
                    'message'        => 'تم إرسال كود التأكيد (OTP) إلى هاتف العميل عبر تطبيق ون كاش أو رسالة SMS.',
                ];
            }

            return [
                'success' => false,
                'status'  => 'failed',
                'message' => 'فشل بدء العملية مع ون كاش: ' . ($response->json('message') ?? 'خطأ في السيرفر'),
            ];
        } catch (Exception $e) {
            Log::error("[OneCashGateway] Initiate Error: " . $e->getMessage());
            return [
                'success' => false,
                'status'  => 'error',
                'message' => 'تعذر الاتصال ببوابة ون كاش: ' . $e->getMessage(),
            ];
        }
    }

    public function verifyPayment(string $referenceId, array $data): array
    {
        if (!$this->isConfigured()) {
            return ['success' => false, 'status' => 'unconfigured', 'message' => 'مفاتيح ون كاش غير مضبوطة'];
        }

        try {
            $response = Http::timeout(15)
                ->withHeaders(['X-Merchant-ID' => $this->merchantId])
                ->post("{$this->baseUrl}/merchant/checkout/verify", [
                    'reference' => $referenceId,
                    'otp'       => $data['otp'] ?? '',
                ]);

            if ($response->successful() && $response->json('status') === 'SUCCESS') {
                return [
                    'success'      => true,
                    'status'       => 'completed',
                    'reference_id' => $referenceId,
                    'amount'       => (float) $response->json('data.amount', 0),
                ];
            }

            return [
                'success' => false,
                'status'  => 'failed',
                'message' => $response->json('message') ?? 'رمز التأكيد غير صحيح أو انتهت صلاحيته.',
            ];
        } catch (Exception $e) {
            return ['success' => false, 'status' => 'error', 'message' => $e->getMessage()];
        }
    }

    public function queryStatus(string $referenceId): array
    {
        if (!$this->isConfigured()) return ['status' => 'unconfigured'];

        try {
            $res = Http::get("{$this->baseUrl}/merchant/checkout/status/{$referenceId}?merchant_id={$this->merchantId}");
            return $res->json() ?? ['status' => 'unknown'];
        } catch (Exception $e) {
            return ['status' => 'error', 'error' => $e->getMessage()];
        }
    }

    public function handleWebhook(array $payload, array $headers): array
    {
        $signature = $headers['x-signature'][0] ?? $headers['X-Signature'] ?? '';
        $reference = $payload['reference'] ?? $payload['reference_id'] ?? '';
        $amount    = (float) ($payload['amount'] ?? 0);
        $status    = strtoupper($payload['status'] ?? '');

        // Verify webhook signature if secret key is present
        if ($this->isConfigured() && !empty($signature)) {
            $expected = hash_hmac('sha256', $this->merchantId . $reference . $amount, $this->secretKey);
            if (!hash_equals($expected, $signature)) {
                return ['verified' => false, 'message' => 'Invalid signature'];
            }
        }

        return [
            'verified'     => true,
            'reference_id' => $reference,
            'status'       => ($status === 'SUCCESS' || $status === 'COMPLETED') ? 'completed' : 'failed',
            'amount'       => $amount,
        ];
    }
}
