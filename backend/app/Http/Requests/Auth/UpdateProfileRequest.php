<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => 'nullable|string|max:255',
            'email' => 'nullable|email|unique:users,email,' . $this->user()->id,
            'fcm_token' => 'nullable|string',
            'app_language' => 'nullable|string|in:ar,en',
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg|max:5120',
        ];
    }
}
