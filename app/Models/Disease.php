<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Disease extends Model
{
    public function healthyValues()
    {
        return $this->hasMany(HealthyValue::class);
    }
}
