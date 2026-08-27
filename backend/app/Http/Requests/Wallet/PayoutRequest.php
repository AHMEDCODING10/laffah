<?php

namespace App\Http\Requests\Wallet;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class PayoutRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'amount' => 'required|numeric|min:500',
            'payout_method' => 'required|string|in:kuraimi,tadhamon,jeeb,cac,onecash,jawali,floosak,cash',
            'account_number' => 'nullable|string|max:50',
            'account_name' => 'nullable|string|max:100',
        ];
    }
}
