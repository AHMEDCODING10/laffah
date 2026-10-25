<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterPassengerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255', 'regex:/^[\p{L}\s]+$/u'],
            'email' => 'nullable|email|unique:users,email',
            'phone' => ['required', 'string', 'unique:users,phone', 'regex:/^(\+?967)?(77|78|73|71|70)[0-9]{7}$/'],
            'password' => 'required|string|min:6',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'الاسم الكامل مطلوب.',
            'name.regex' => 'يجب أن يحتوي الاسم على أحرف فقط بدون أرقام.',
            'phone.required' => 'رقم الهاتف مطلوب.',
            'phone.unique' => 'رقم الهاتف مسجل مسبقاً.',
            'phone.regex' => 'رقم الهاتف يجب أن يكون رقماً يمنياً صالحاً يبدأ بـ (77 أو 78 أو 73 أو 71 أو 70).',
            'password.required' => 'كلمة المرور مطلوبة.',
            'password.min' => 'كلمة المرور يجب أن لا تقل عن 6 أحرف.',
        ];
    }
}
