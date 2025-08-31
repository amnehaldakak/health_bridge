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

    public function createdCommunities()
    {
        return $this->hasMany(Community::class);//, 'doctor_id'
    }

    public function communityMemberships()
    {
        return $this->hasMany(CommunityMember::class);//, 'member_id'
    }

    public function communityPosts()
    {
        return $this->hasMany(CommunityPost::class);//, 'author_id'
    }

    public function postComments()
    {
        return $this->hasMany(PostComment::class);//, 'commenter_id'
    }

}
