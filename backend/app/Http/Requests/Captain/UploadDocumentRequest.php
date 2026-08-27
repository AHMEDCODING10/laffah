<?php

namespace App\Http\Requests\Captain;

use Illuminate\Foundation\Http\FormRequest;

class UploadDocumentRequest extends FormRequest
{
    public function authorize()
    {
        return $this->user() && $this->user()->hasRole('captain') && $this->user()->captainProfile;
    }

    public function rules()
    {
        return [
            'type' => 'required|string|in:id_card,vehicle_registration',
            'file' => 'required|file|mimes:jpeg,png,jpg,pdf|max:5120',
        ];
    }
}
