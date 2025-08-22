<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HealthyValue extends Model
{

    protected $fillable = ['patient_id', 'disease_id','value','valuee','status'];
    protected $attributes = [
        'valuee' => 0,
        'status' => 'default_value',
    ];
    protected $guarded=[];
    public function patient()
    {
        return $this->belongsTo(Patient::class, 'patient_id');
    }
    public function disease()
    {
        return $this->belongsTo(Disease::class, 'disease_id');
    }
}
