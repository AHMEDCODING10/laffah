<?php

namespace App\Http\Requests\Trip;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class CreateTripRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Prepare the data for validation (normalize frontend field aliases & fallbacks).
     */
    protected function prepareForValidation(): void
    {
        $pickupAddress = $this->input('pickup_address') ?? $this->input('pickup_location') ?? 'موقع الانطلاق';
        $dropoffAddress = $this->input('dropoff_address') ?? $this->input('dropoff_location') ?? 'وجهة الوصول';

        // Fallback default coordinates (Sana'a, Yemen center) if not provided
        $pickupLat = $this->input('pickup_latitude') ?? $this->input('pickup_lat') ?? 15.3694;
        $pickupLng = $this->input('pickup_longitude') ?? $this->input('pickup_lng') ?? $this->input('pickup_lon') ?? 44.1910;

        $dropoffLat = $this->input('dropoff_latitude') ?? $this->input('dropoff_lat') ?? 15.3521;
        $dropoffLng = $this->input('dropoff_longitude') ?? $this->input('dropoff_lng') ?? $this->input('dropoff_lon') ?? 44.2014;

        $type = $this->input('type') ?? ($this->input('ride_type') === 'delivery' ? 'delivery' : 'ride');

        $this->merge([
            'pickup_address' => $pickupAddress,
            'dropoff_address' => $dropoffAddress,
            'pickup_latitude' => (float) $pickupLat,
            'pickup_longitude' => (float) $pickupLng,
            'dropoff_latitude' => (float) $dropoffLat,
            'dropoff_longitude' => (float) $dropoffLng,
            'type' => in_array($type, ['ride', 'delivery']) ? $type : 'ride',
        ]);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'type' => 'nullable|string|in:ride,delivery',
            'pickup_address' => 'required|string|max:255',
            'pickup_latitude' => 'required|numeric|between:12.0,19.5',
            'pickup_longitude' => 'required|numeric|between:41.5,54.5',
            'dropoff_address' => 'required|string|max:255',
            'dropoff_latitude' => 'required|numeric|between:12.0,19.5',
            'dropoff_longitude' => 'required|numeric|between:41.5,54.5',
            'promo_code_id' => 'nullable|integer|exists:promo_codes,id',
            'stops' => 'nullable|array',
            'stops.*.address' => 'required_with:stops|string|max:255',
            'stops.*.latitude' => 'required_with:stops|numeric|between:12.0,19.5',
            'stops.*.longitude' => 'required_with:stops|numeric|between:41.5,54.5',
            'is_scheduled' => 'nullable|boolean',
            'scheduled_time' => 'nullable|date|after:now',
            'payment_method' => 'nullable|string|in:cash,wallet',
        ];
    }
}