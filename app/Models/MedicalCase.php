<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MedicalCase extends Model
{

    protected $fillable = [
        'id',
        'patient_id',
        'doctor_id',
        'chief_complaint',
        'symptoms',
        'medical_history',
        'surgical_history',
        'allergic_history',
        'smoking_status',
        'signs',
        'vital_signs',
        'clinical_examination_results',
        'echo',
        'lab_test',
        'diagnosis'
    ];
    public function doctor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function medicationGroups()
    {
        return $this->hasMany(MedicationGroup::class, 'case_id');
    }
}
