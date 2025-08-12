<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Patient extends Model
{
        protected $fillable = [
        'user_id',
        'birth_date',
        'gender',
        'phone',
        'chronic_diseases',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function medicalCase()
    {
        return $this->hasMany(MedicalCase::class);
    }

    public function medications()
    {
        return $this->hasMany(Medication::class, 'patient_id');
    }

    public function healthyValues()
    {
        return $this->hasMany(HealthyValue::class, 'patient_id');
    }

}
