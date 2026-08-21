<?php

namespace App\Livewire\Admin;

use App\Models\Setting;
use Illuminate\Support\Facades\Cache;
use Livewire\Component;

class SettingsManager extends Component
{
    public string $pricePerKmKey = 'price_per_km';
    public string $multiStopFeeKey = 'multi_stop_fee';
    public string $commissionPercentKey = 'commission_percent';
    public string $parcelPercentSmallKey = 'parcel_percent_small';
    public string $parcelPercentMediumKey = 'parcel_percent_medium';
    public string $parcelPercentLargeKey = 'parcel_percent_large';
    public string $appNameKey = 'app_name';
    public string $supportPhoneKey = 'support_phone';
    public string $searchRadiusKey = 'search_radius_km';
    public string $minWithdrawalKey = 'min_withdrawal_amount';

    public string $pricePerKm = '';
    public string $multiStopFee = '';
    public string $commissionPercent = '';
    public string $parcelPercentSmall = '';
    public string $parcelPercentMedium = '';
    public string $parcelPercentLarge = '';
    public string $appName = '';
    public string $supportPhone = '';
    public string $searchRadius = '';
    public string $minWithdrawal = '';

    public function mount(): void
    {
        $settings = Setting::whereIn('key', [
            $this->pricePerKmKey,
            $this->multiStopFeeKey,
            $this->commissionPercentKey,
            $this->parcelPercentSmallKey,
            $this->parcelPercentMediumKey,
            $this->parcelPercentLargeKey,
            $this->appNameKey,
            $this->supportPhoneKey,
            $this->searchRadiusKey,
            $this->minWithdrawalKey,
        ])->pluck('value', 'key');

        $this->pricePerKm = $settings[$this->pricePerKmKey] ?? '175';
        $this->multiStopFee = $settings[$this->multiStopFeeKey] ?? '300';
        $this->commissionPercent = $settings[$this->commissionPercentKey] ?? '15';
        $this->parcelPercentSmall = $settings[$this->parcelPercentSmallKey] ?? '10';
        $this->parcelPercentMedium = $settings[$this->parcelPercentMediumKey] ?? '15';
        $this->parcelPercentLarge = $settings[$this->parcelPercentLargeKey] ?? '20';
        $this->appName = $settings[$this->appNameKey] ?? 'لَفَّة';
        $this->supportPhone = $settings[$this->supportPhoneKey] ?? '770291452';
        $this->searchRadius = $settings[$this->searchRadiusKey] ?? '10';
        $this->minWithdrawal = $settings[$this->minWithdrawalKey] ?? '1000';
    }

    public function savePricing(): void
    {
        $this->validate([
            'pricePerKm'          => 'required|numeric|min:1',
            'multiStopFee'        => 'required|numeric|min:0',
            'commissionPercent'   => 'required|numeric|min:0|max:100',
            'parcelPercentSmall'  => 'required|numeric|min:0|max:100',
            'parcelPercentMedium' => 'required|numeric|min:0|max:100',
            'parcelPercentLarge'  => 'required|numeric|min:0|max:100',
        ]);

        Setting::updateOrCreate(['key' => $this->pricePerKmKey],          ['value' => $this->pricePerKm, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->multiStopFeeKey],        ['value' => $this->multiStopFee, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->commissionPercentKey],   ['value' => $this->commissionPercent, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->parcelPercentSmallKey],  ['value' => $this->parcelPercentSmall, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->parcelPercentMediumKey], ['value' => $this->parcelPercentMedium, 'type' => 'number', 'group' => 'pricing']);
        Setting::updateOrCreate(['key' => $this->parcelPercentLargeKey],  ['value' => $this->parcelPercentLarge, 'type' => 'number', 'group' => 'pricing']);

        // Flush ALL pricing cache keys so next request always reads latest values
        foreach (['system_settings','setting_price_per_km',
                  'setting_multi_stop_fee',
                  'setting_commission_percent',
                  'setting_parcel_percent_small','setting_parcel_percent_medium',
                  'setting_parcel_percent_large'] as $key) {
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
            'minWithdrawal' => 'required|numeric|min:100',
        ]);

        Setting::updateOrCreate(['key' => $this->appNameKey],       ['value' => $this->appName, 'type' => 'string', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->supportPhoneKey],  ['value' => $this->supportPhone, 'type' => 'string', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->searchRadiusKey],  ['value' => $this->searchRadius, 'type' => 'number', 'group' => 'general']);
        Setting::updateOrCreate(['key' => $this->minWithdrawalKey], ['value' => $this->minWithdrawal, 'type' => 'number', 'group' => 'general']);

        Cache::forget('system_settings');
        Cache::forget('setting_search_radius_km');

        session()->flash('success', 'تم حفظ الإعدادات العامة والتشغيلية بنجاح.');
    }

    public function render()
    {
        return view('livewire.admin.settings-manager');
    }
}