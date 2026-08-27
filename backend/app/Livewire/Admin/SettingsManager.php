<?php

namespace App\Livewire\Admin;

use App\Models\Setting;
use Illuminate\Support\Facades\Cache;
use Livewire\Component;

class SettingsManager extends Component
{
    public string $baseFareKey = 'base_fare';
    public string $pricePerKmKey = 'price_per_km';
    public string $minFareKey = 'min_fare';
    public string $multiStopFeeKey = 'multi_stop_fee';
    public string $commissionPercentKey = 'commission_percent';
    public string $parcelPriceSmallKey = 'parcel_price_small';
    public string $parcelPriceMediumKey = 'parcel_price_medium';
    public string $parcelPriceLargeKey = 'parcel_price_large';
    public string $appNameKey = 'app_name';
    public string $supportPhoneKey = 'support_phone';
    public string $searchRadiusKey = 'search_radius_km';
    public string $maxCaptainDebtKey = 'max_captain_debt';
    public string $minWithdrawalKey = 'min_withdrawal_amount';

    public string $baseFare = '';
    public string $pricePerKm = '';
    public string $minFare = '';
    public string $multiStopFee = '';
    public string $commissionPercent = '';
    public string $parcelPriceSmall = '';
    public string $parcelPriceMedium = '';
    public string $parcelPriceLarge = '';
    public string $appName = '';
    public string $supportPhone = '';
    public string $searchRadius = '';
    public string $maxCaptainDebt = '';
    public string $minWithdrawal = '';

    public function mount(): void
    {
        $settings = Setting::whereIn('key', [
            $this->baseFareKey,
            $this->pricePerKmKey,
            $this->minFareKey,
            $this->multiStopFeeKey,
            $this->commissionPercentKey,
            $this->parcelPriceSmallKey,
            $this->parcelPriceMediumKey,
            $this->parcelPriceLargeKey,
            $this->appNameKey,
            $this->supportPhoneKey,
            $this->searchRadiusKey,
            $this->maxCaptainDebtKey,
            $this->minWithdrawalKey,
        ])->pluck('value', 'key');

        $this->baseFare = $settings[$this->baseFareKey] ?? '500';
        $this->pricePerKm = $settings[$this->pricePerKmKey] ?? '150';
        $this->minFare = $settings[$this->minFareKey] ?? '800';
        $this->multiStopFee = $settings[$this->multiStopFeeKey] ?? '300';
        $this->commissionPercent = $settings[$this->commissionPercentKey] ?? '15';
        $this->parcelPriceSmall = $settings[$this->parcelPriceSmallKey] ?? '1200';
        $this->parcelPriceMedium = $settings[$this->parcelPriceMediumKey] ?? '1500';
        $this->parcelPriceLarge = $settings[$this->parcelPriceLargeKey] ?? '2000';
        $this->appName = $settings[$this->appNameKey] ?? 'لَفَّة';
        $this->supportPhone = $settings[$this->supportPhoneKey] ?? '770291452';
        $this->searchRadius = $settings[$this->searchRadiusKey] ?? '10';
        $this->maxCaptainDebt = $settings[$this->maxCaptainDebtKey] ?? '5000';
        $this->minWithdrawal = $settings[$this->minWithdrawalKey] ?? '1000';
    }

    public function savePricing(): void
    {
        $this->validate([
            'baseFare'          => 'required|numeric|min:0',
            'pricePerKm'        => 'required|numeric|min:0',
            'minFare'           => 'required|numeric|min:0',
            'multiStopFee'      => 'required|numeric|min:0',
            'commissionPercent' => 'required|numeric|min:0|max:100',
            'parcelPriceSmall'  => 'required|numeric|min:0',
            'parcelPriceMedium' => 'required|numeric|min:0',
            'parcelPriceLarge'  => 'required|numeric|min:0',
        ]);

        Setting::updateOrCreate(['key' => $this->baseFareKey],         ['value' => $this->baseFare, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->pricePerKmKey],       ['value' => $this->pricePerKm, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->minFareKey],          ['value' => $this->minFare, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->multiStopFeeKey],     ['value' => $this->multiStopFee, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->commissionPercentKey],['value' => $this->commissionPercent, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->parcelPriceSmallKey], ['value' => $this->parcelPriceSmall, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->parcelPriceMediumKey],['value' => $this->parcelPriceMedium, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->parcelPriceLargeKey], ['value' => $this->parcelPriceLarge, 'type' => 'number', 'group' => 'pricing']);

        // Flush ALL pricing cache keys so next request always reads latest values
        foreach (['system_settings','setting_base_fare','setting_price_per_km',
                  'setting_min_fare','setting_multi_stop_fee',
                  'setting_commission_percent',
                  'setting_parcel_price_small','setting_parcel_price_medium',
                  'setting_parcel_price_large'] as $key) {
            Cache::forget($key);
        }

        session()->flash('success', 'تم حفظ وتحديث إعدادات التسعير بنجاح.');
    }

    public function saveGeneral(): void
    {
        $this->validate([
            'appName' => 'required|string|max:100',
            'supportPhone' => 'nullable|string|max:20',
            'searchRadius' => 'required|numeric|min:1|max:100',
            'maxCaptainDebt' => 'required|numeric|min:0',
            'minWithdrawal' => 'required|numeric|min:100',
        ]);

        Setting::updateOrCreate(['key' => $this->appNameKey],       ['value' => $this->appName, 'type' => 'string', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->supportPhoneKey],  ['value' => $this->supportPhone, 'type' => 'string', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->searchRadiusKey],  ['value' => $this->searchRadius, 'type' => 'number', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->maxCaptainDebtKey],['value' => $this->maxCaptainDebt, 'type' => 'number', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->minWithdrawalKey], ['value' => $this->minWithdrawal, 'type' => 'number', 'group' => 'general']);

        Cache::forget('system_settings');

        session()->flash('success', 'تم حفظ الإعدادات العامة والتشغيلية بنجاح.');
    }

    public function render()
    {
        return view('livewire.admin.settings-manager');
    }
}