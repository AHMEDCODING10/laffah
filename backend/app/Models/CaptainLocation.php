<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CaptainLocation extends Model
{
    protected $fillable = [
        'captain_profile_id',
        'latitude',
        'longitude',
        'heading',
        'speed',
        'last_updated_at',
    ];

    public $timestamps = true;

    protected $casts = [
        'last_updated_at' => 'datetime',
    ];

    public function profile()
    {
        return $this->belongsTo(CaptainProfile::class, 'captain_profile_id');
    }
}
