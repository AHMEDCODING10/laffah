<?php

namespace App\Http\Requests\Auth;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class RegisterCaptainRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
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
            'name' => ['required', 'string', 'max:255', 'regex:/^[\p{L}\s]+$/u'],
            'phone' => ['required', 'string', 'unique:users,phone', 'regex:/^(\+?967)?(77|78|73|71|70)[0-9]{7}$/'],
            'email' => 'nullable|email|unique:users,email',
            'password' => 'required|string|min:6',
            'vehicle_type' => 'nullable|string|max:255',
            'vehicle_model' => 'nullable|string|max:255',
            'vehicle_year' => 'nullable',
            'vehicle_plate' => ['nullable', 'string', 'max:20', 'regex:/^\d{1,2}\/\d{1,5}$/'],
            'plate_number' => ['nullable', 'string', 'max:20', 'regex:/^\d{1,2}\/\d{1,5}$/'],
            'vehicle_color' => 'nullable|string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'اسم الكابتن مطلوب.',
            'name.regex' => 'يجب أن يحتوي الاسم على أحرف فقط بدون أرقام.',
            'phone.required' => 'رقم الهاتف مطلوب.',
            'phone.unique' => 'رقم الهاتف مسجل مسبقاً.',
            'phone.regex' => 'رقم الهاتف يجب أن يكون رقماً يمنياً صالحاً يبدأ بـ (77 أو 78 أو 73 أو 71 أو 70).',
            'password.required' => 'كلمة المرور مطلوبة.',
            'password.min' => 'كلمة المرور يجب أن لا تقل عن 6 أحرف.',
            'vehicle_plate.regex' => 'صيغة رقم اللوحة غير صحيحة، مثال: 1/12345 (بحد أقصى 6 أرقام).',
            'plate_number.regex' => 'صيغة رقم اللوحة غير صحيحة، مثال: 1/12345 (بحد أقصى 6 أرقام).',
        ];
    }
}