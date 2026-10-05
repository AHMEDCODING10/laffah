<?php

namespace App\Services\PaymentGateways\Drivers;

use App\Services\PaymentGateways\PaymentGatewayInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class KuraimiGateway implements PaymentGatewayInterface
{
    protected string $merchantCode;
    protected string $terminalId;
    protected string $secretKey;
    protected string $baseUrl;

    public function __construct()
    {
        $this->merchantCode = env('KURAIMI_MERCHANT_CODE', '');
        $this->terminalId   = env('KURAIMI_TERMINAL_ID', '');
        $this->secretKey    = env('KURAIMI_SECRET_KEY', '');
        $this->baseUrl      = env('KURAIMI_BASE_URL', 'https://services.kuraimibank.com/haseb/v1');
    }

    public function getIdentifier(): string
    {
        return 'kuraimi';
    }

    public function isConfigured(): bool
    {
        return !empty($this->merchantCode) && !empty($this->secretKey);
    }

    public function initiatePayment(array $data): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'status'  => 'unconfigured',
                'message' => 'بوابة الكريمي (حاسب / إم فلوس) بانتظار إدخال مفاتيح الربط التجاري في ملف .env.',
                'guide'   => 'يتطلب الربط: KURAIMI_MERCHANT_CODE, KURAIMI_TERMINAL_ID, KURAIMI_SECRET_KEY',
            ];
        }

        try {
            $response = Http::timeout(15)
                ->withHeaders([
                    'X-Merchant-Code' => $this->merchantCode,
                    'X-Terminal-ID'   => $this->terminalId,
                ])
                ->post("{$this->baseUrl}/payment/request-otp", [
                    'merchant_code' => $this->merchantCode,
                    'account_no'    => $data['sender_account'] ?? '',
                    'phone'         => $data['phone'] ?? '',
                    'amount'        => $data['amount'],
                    'currency'      => 1, // YER
                    'reference'     => $data['reference_id'],
                ]);

            if ($response->successful() && $response->json('code') == 200) {
                return [
                    'success'        => true,
                    'status'         => 'pending_otp',
                    'transaction_id' => $response->json('transaction_id') ?? $data['reference_id'],
                    'mode'           => 'otp',
                    'message'        => 'تم إرسال كود التأكيد إلى هاتفك المسجل في بنك الكريمي.',
                ];
            }

            return [
                'success' => false,
                'status'  => 'failed',
                'message' => $response->json('message') ?? 'فشل طلب الخصم من حساب الكريمي.',
            ];
        } catch (Exception $e) {
            Log::error("[KuraimiGateway] Error: " . $e->getMessage());
            return [
                'success' => false,
                'status'  => 'error',
                'message' => 'تعذر الاتصال بخدمة الكريمي حاسب: ' . $e->getMessage(),
            ];
        }
    }

    public function verifyPayment(string $referenceId, array $data): array
    {
        if (!$this->isConfigured()) return ['success' => false, 'status' => 'unconfigured'];

        try {
            $response = Http::timeout(15)->post("{$this->baseUrl}/payment/confirm", [
                'merchant_code' => $this->merchantCode,
                'reference'     => $referenceId,
                'otp'           => $data['otp'] ?? '',
            ]);

            if ($response->successful() && $response->json('status') === 'SUCCESS') {
                return [
                    'success'      => true,
                    'status'       => 'completed',
                    'reference_id' => $referenceId,
                    'amount'       => (float) $response->json('amount', 0),
                ];
            }

            return ['success' => false, 'status' => 'failed', 'message' => $response->json('message') ?? 'رمز التأكيد غير صحيح'];
        } catch (Exception $e) {
            return ['success' => false, 'status' => 'error', 'message' => $e->getMessage()];
        }
    }

    public function queryStatus(string $referenceId): array
    {
        if (!$this->isConfigured()) return ['status' => 'unconfigured'];

        try {
            return Http::get("{$this->baseUrl}/payment/status/{$referenceId}?merchant={$this->merchantCode}")->json();
        } catch (Exception $e) {
            return ['status' => 'error', 'error' => $e->getMessage()];
        }
    }

    public function handleWebhook(array $payload, array $headers): array
    {
        return [
            'verified'     => true,
            'reference_id' => $payload['reference'] ?? '',
            'status'       => ($payload['status'] ?? '') === 'SUCCESS' ? 'completed' : 'failed',
            'amount'       => (float) ($payload['amount'] ?? 0),
        ];
    }
}
