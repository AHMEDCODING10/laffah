<?php

namespace App\Services\PaymentGateways;

interface PaymentGatewayInterface
{
    /**
     * Get unique channel identifier (onecash, kuraimi, jawali, jeeb, mock).
     */
    public function getIdentifier(): string;

    /**
     * Initiate a payment or deposit request with the bank/wallet.
     *
     * @param array $data ['amount', 'phone', 'currency', 'reference_id', 'description', 'user_id', 'callback_url']
     * @return array ['success' => bool, 'transaction_id' => string, 'status' => string, 'mode' => 'otp'|'redirect'|'ussd', 'message' => string]
     */
    public function initiatePayment(array $data): array;

    /**
     * Verify payment OTP entered by customer.
     *
     * @param string $referenceId
     * @param array $data ['otp' => string, 'phone' => string]
     * @return array ['success' => bool, 'status' => 'completed'|'failed', 'reference_id' => string, 'amount' => float]
     */
    public function verifyPayment(string $referenceId, array $data): array;

    /**
     * Query remote transaction status from the gateway.
     */
    public function queryStatus(string $referenceId): array;

    /**
     * Validate and process incoming bank webhook payload.
     *
     * @param array $payload Incoming request data
     * @param array $headers Incoming request headers
     * @return array ['verified' => bool, 'reference_id' => string, 'status' => 'completed'|'failed', 'amount' => float]
     */
    public function handleWebhook(array $payload, array $headers): array;
}
