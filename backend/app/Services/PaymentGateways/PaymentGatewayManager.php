<?php

namespace App\Services\PaymentGateways;

use App\Services\PaymentGateways\Drivers\OneCashGateway;
use App\Services\PaymentGateways\Drivers\KuraimiGateway;
use App\Services\PaymentGateways\Drivers\WeCashGateway;
use App\Services\PaymentGateways\Drivers\MockGateway;
use InvalidArgumentException;

class PaymentGatewayManager
{
    protected array $drivers = [];

    public function __construct()
    {
        $this->drivers = [
            'onecash' => new OneCashGateway(),
            'kuraimi' => new KuraimiGateway(),
            'jawali'  => new WeCashGateway(),
            'mock'    => new MockGateway(),
        ];
    }

    /**
     * Get specific gateway driver.
     */
    public function driver(?string $name = null): PaymentGatewayInterface
    {
        $name = strtolower($name ?: 'mock');

        if (isset($this->drivers[$name])) {
            return $this->drivers[$name];
        }

        // Return mock driver for unsupported or local testing
        if (app()->environment('local', 'testing')) {
            return $this->drivers['mock'];
        }

        throw new InvalidArgumentException("بوابة الدفع الإلكتروني '{$name}' غير مدعومة حالياً.");
    }

    /**
     * Check if a gateway has live credentials configured.
     */
    public function isConfigured(string $name): bool
    {
        try {
            $driver = $this->driver($name);
            if (method_exists($driver, 'isConfigured')) {
                return $driver->isConfigured();
            }
            return false;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Get readiness report of all gateways.
     */
    public function getReadinessReport(): array
    {
        return [
            'onecash' => [
                'name'        => 'ون كاش (OneCash)',
                'configured'  => $this->isConfigured('onecash'),
                'required'    => ['ONECASH_MERCHANT_ID', 'ONECASH_TERMINAL_ID', 'ONECASH_SECRET_KEY'],
                'webhook_url' => url('/api/v1/payments/onecash/webhook'),
            ],
            'kuraimi' => [
                'name'        => 'الكريمي (حاسب / إم فلوس)',
                'configured'  => $this->isConfigured('kuraimi'),
                'required'    => ['KURAIMI_MERCHANT_CODE', 'KURAIMI_TERMINAL_ID', 'KURAIMI_SECRET_KEY'],
                'webhook_url' => url('/api/v1/payments/kuraimi/webhook'),
            ],
            'jawali'  => [
                'name'        => 'جوالي (WeCash / كاك بنك)',
                'configured'  => $this->isConfigured('jawali'),
                'required'    => ['WECASH_CLIENT_ID', 'WECASH_CLIENT_SECRET', 'WECASH_MERCHANT_CODE'],
                'webhook_url' => url('/api/v1/payments/jawali/webhook'),
            ],
        ];
    }
}
