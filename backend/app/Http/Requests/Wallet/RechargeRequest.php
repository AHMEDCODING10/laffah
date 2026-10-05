<?php

namespace App\Http\Requests\Wallet;

use Illuminate\Foundation\Http\FormRequest;

class RechargeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'amount' => 'required|numeric|min:500|max:100000',
            'payment_method' => 'required|string|in:kuraimi,tadhamon,jeeb,cac,onecash,jawali,floosak,cash',
            'reference_id' => 'required|string|min:4|max:50',
            'sender_account' => 'nullable|string|max:100',
            'receipt_image' => 'nullable|file|mimes:jpeg,png,jpg,webp,pdf|max:5120',
            'receipt_url' => 'nullable|string|max:500',
            'notes' => 'nullable|string|max:500',
        ];
    }

    public function messages(): array
    {
        return [
            'amount.required' => 'يرجى إدخال مبلغ الشحن.',
            'amount.numeric' => 'مبلغ الشحن يجب أن يكون رقماً صحيحاً.',
            'amount.min' => 'الحد الأدنى للشحن هو 500 ريال يمني.',
            'amount.max' => 'الحد الأقصى للشحن للعملية الواحدة هو 100,000 ريال يمني.',
            'payment_method.required' => 'يرجى اختيار وسيلة الدفع أو المحفظة الإلكترونية.',
            'payment_method.in' => 'وسيلة الدفع المختارة غير مدعومة.',
            'reference_id.required' => 'يرجى إدخال رقم العملية / رقم الإشعار الصادر من المحفظة.',
            'reference_id.min' => 'رقم العملية يجب أن يتكون من 4 أرقام/حروف على الأقل.',
        ];
    }
}