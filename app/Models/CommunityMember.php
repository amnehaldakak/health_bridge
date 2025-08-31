<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CommunityMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'community_id',
        'patient_id',
        'doctor_id',
        'role',
        'join_date'
    ];

    public function community()
    {
        return $this->belongsTo(Community::class);
    }


    public function doctor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }
    
}
