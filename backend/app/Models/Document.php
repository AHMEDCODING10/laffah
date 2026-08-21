<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Document extends Model
{
    protected $fillable = [
        'captain_profile_id',
        'type',
        'file_path',
        'status',
        'rejection_reason',
    ];

    public function captainProfile()
    {
        return $this->belongsTo(CaptainProfile::class);
    }
}
