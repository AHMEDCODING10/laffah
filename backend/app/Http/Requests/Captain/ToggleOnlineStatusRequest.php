<?php

namespace App\Http\Requests\Captain;

use Illuminate\Foundation\Http\FormRequest;

class ToggleOnlineStatusRequest extends FormRequest
{
    public function authorize()
    {
        return $this->user() && $this->user()->hasRole('captain') && $this->user()->captainProfile;
    }

    public function rules()
    {
        return [
            'is_online' => 'required|boolean',
        ];
    }
}
