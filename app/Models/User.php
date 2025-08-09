<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'age',
        'chronic_diseases',
        'specialization',
        'clinic',
        'role',
        'is_approved',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function doctorVerification()
    {
        return $this->hasOne(DoctorVerification::class, 'doctor_id');
    }

    public function isApprovedDoctor()
    {
        return $this->role === 'doctor' && $this->is_approved;
    }

    public function doctorCases()
    {
        return $this->hasMany(MedicalCase::class, 'doctor_id');
    }

    public function patientCases()
    {
        return $this->hasMany(MedicalCase::class, 'patient_id');
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
