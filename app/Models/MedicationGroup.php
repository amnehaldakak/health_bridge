<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MedicationGroup extends Model
{

    //protected $primaryKey = 'group_id';
        protected $fillable = [
        'case_id',
        'patient_id',
        'doctor_id',
        'prescription_date'
        ];

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function doctor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function medicalCase()
    {
        return $this->belongsTo(MedicalCase::class, 'case_id');
    }

    public function medications()
    {
        return $this->hasMany(Medication::class, 'group_id', 'group_id');
    }
}
