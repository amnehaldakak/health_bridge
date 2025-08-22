<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ReminderTime extends Model
{
    protected $fillable = [
        'medication_id',
        'date',
        'time',
        'status'
    ];

    public function medication()
    {
        return $this->belongsTo(Medication::class, 'medication_id', 'medication_id');
    }
}
