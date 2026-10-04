<?php

namespace App\Http\Requests\Trip;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class EstimateTripRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Prepare the data for validation (normalize promo codes).
     */
     protected function prepareForValidation(): void
     {
         if ($this->filled('promo_code') && !$this->filled('promo_code_id')) {
             $promoId = \App\Models\PromoCode::where('code', trim($this->input('promo_code')))->value('id');
             if ($promoId) {
                 $this->merge(['promo_code_id' => $promoId]);
             }
         }
     }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'pickup_latitude' => 'required|numeric|between:12.0,19.5',
            'pickup_longitude' => 'required|numeric|between:41.5,54.5',
            'dropoff_latitude' => 'required|numeric|between:12.0,19.5',
            'dropoff_longitude' => 'required|numeric|between:41.5,54.5',
            'stops' => 'nullable|array',
            'stops.*.latitude' => 'required_with:stops|numeric|between:12.0,19.5',
            'stops.*.longitude' => 'required_with:stops|numeric|between:41.5,54.5',
            'promo_code_id' => 'nullable|integer|exists:promo_codes,id',
            'promo_code' => 'nullable|string|max:50',
        ];
    }
}
