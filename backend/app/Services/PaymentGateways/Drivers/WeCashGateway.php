<?php

namespace App\Services\PaymentGateways\Drivers;

use App\Services\PaymentGateways\PaymentGatewayInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class WeCashGateway implements PaymentGatewayInterface
{
    protected string $clientId;
    protected string $clientSecret;
    protected string $merchantCode;
    protected string $baseUrl;

    public function __construct()
    {
        $this->clientId     = env('WECASH_CLIENT_ID', '');
        $this->clientSecret = env('WECASH_CLIENT_SECRET', '');
        $this->merchantCode = env('WECASH_MERCHANT_CODE', '');
        $this->baseUrl      = env('WECASH_BASE_URL', 'https://api.wecash.ye/v1');
    }

    public function getIdentifier(): string
    {
        return 'jawali';
    }

    public function isConfigured(): bool
    {
        return !empty($this->clientId) && !empty($this->clientSecret);
    }

    public function initiatePayment(array $data): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'status'  => 'unconfigured',
                'message' => 'بوابة جوالي (WeCash) بانتظار إدخال مفاتيح الربط التجاري في ملف .env.',
                'guide'   => 'يتطلب الربط: WECASH_CLIENT_ID, WECASH_CLIENT_SECRET, WECASH_MERCHANT_CODE',
            ];
        }

        try {
            $response = Http::timeout(15)
                ->withBasicAuth($this->clientId, $this->clientSecret)
                ->post("{$this->baseUrl}/c2b/request", [
                    'merchant' => $this->merchantCode,
                    'phone'    => $data['phone'] ?? $data['sender_account'] ?? '',
                    'amount'   => $data['amount'],
                    'order_id' => $data['reference_id'],
                ]);

            if ($response->successful()) {
                return [
                    'success'        => true,
                    'status'         => 'pending_otp',
                    'transaction_id' => $response->json('transaction_id') ?? $data['reference_id'],
                    'mode'           => 'otp',
                    'message'        => 'تم إرسال إشعار الخصم إلى محفظة جوالي الخاصة بك.',
                ];
            }

            return ['success' => false, 'status' => 'failed', 'message' => $response->json('message') ?? 'فشل طلب الدفع عبر جوالي'];
        } catch (Exception $e) {
            Log::error("[WeCashGateway] Error: " . $e->getMessage());
            return ['success' => false, 'status' => 'error', 'message' => $e->getMessage()];
        }
    }

    public function verifyPayment(string $referenceId, array $data): array
    {
        return ['success' => false, 'status' => 'unsupported'];
    }

    public function queryStatus(string $referenceId): array
    {
        if (!$this->isConfigured()) return ['status' => 'unconfigured'];
        return Http::withBasicAuth($this->clientId, $this->clientSecret)->get("{$this->baseUrl}/c2b/status/{$referenceId}")->json() ?? [];
    }

    public function handleWebhook(array $payload, array $headers): array
    {
        $status = strtoupper($payload['status'] ?? '');
        return [
            'verified'     => true,
            'reference_id' => $payload['order_id'] ?? $payload['reference'] ?? '',
            'status'       => ($status === 'SUCCESS' || $status === 'PAID') ? 'completed' : 'failed',
            'amount'       => (float) ($payload['amount'] ?? 0),
        ];
    }
}
