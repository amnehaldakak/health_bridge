<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DoctorVerification extends Model
{

    protected $fillable = [
        'doctor_id',
        'certificate_path',
        'status',
        'rejection_reason'
    ];
    
    public function doctor()
    {
        return $this->belongsTo(User::class, 'doctor_id');
    }
}
