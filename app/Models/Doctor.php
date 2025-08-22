<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Doctor extends Model
{
        protected $fillable = [
        'user_id',
        'specialization',
        'clinic_address',
        'clinic_phone',
        'certificate_path',
        'verification_status',
        'rejection_reason',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    public function medicalCase()
    {
        return $this->hasMany(MedicalCase::class);
    }

    public function medicationGroups()
    {
        return $this->hasMany(MedicationGroup::class);
    }

    public function approvals()
    {
        return $this->hasMany(DoctorPatientApproval::class);
    }

}
