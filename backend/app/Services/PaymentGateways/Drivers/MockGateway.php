<?php

namespace App\Services\PaymentGateways\Drivers;

use App\Services\PaymentGateways\PaymentGatewayInterface;

class MockGateway implements PaymentGatewayInterface
{
    public function getIdentifier(): string
    {
        return 'mock';
    }

    public function initiatePayment(array $data): array
    {
        return [
            'success'        => true,
            'status'         => 'pending_otp',
            'transaction_id' => 'MCK-' . strtoupper(bin2hex(random_bytes(4))),
            'mode'           => 'otp',
            'message'        => 'وضع الاختبار التجريبي (Sandbox): تم إرسال كود التأكيد الافتراضي (123456)',
            'test_otp'       => '123456',
        ];
    }

    public function verifyPayment(string $referenceId, array $data): array
    {
        $otp = $data['otp'] ?? '';
        if ($otp === '123456' || $otp === '000000') {
            return [
                'success'      => true,
                'status'       => 'completed',
                'reference_id' => $referenceId,
                'amount'       => (float) ($data['amount'] ?? 1000),
            ];
        }

        return [
            'success' => false,
            'status'  => 'failed',
            'message' => 'رمز الاختبار غير صحيح. استخدم 123456 للنجاح.',
        ];
    }

    public function queryStatus(string $referenceId): array
    {
        return ['status' => 'completed', 'reference_id' => $referenceId];
    }

    public function handleWebhook(array $payload, array $headers): array
    {
        return [
            'verified'     => true,
            'reference_id' => $payload['reference_id'] ?? 'MOCK-REF',
            'status'       => 'completed',
            'amount'       => (float) ($payload['amount'] ?? 1000),
        ];
    }
}
