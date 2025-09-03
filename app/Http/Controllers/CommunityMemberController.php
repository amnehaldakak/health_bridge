<?php

namespace App\Http\Controllers;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Community;
use App\Models\CommunityMember;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class CommunityMemberController extends Controller
{
        public function joinCommunity($communityId)
    {
        $userId = Auth::id();
        
        // البحث عن المجتمع
        $community = Community::findOrFail($communityId);
        
        // التحقق إذا كان المستخدم طبيب أو مريض
        $doctor = Doctor::where('user_id', $userId)->first();
        $patient = Patient::where('user_id', $userId)->first();
        
        if (!$doctor && !$patient) {
            return response()->json([
                'message' => 'Only doctors or patients can join communities'
            ], 403);
        }
        
        // التحقق من عدم وجود عضوية مسبقة
        $existingMember = null;
        
        if ($doctor) {
            $existingMember = CommunityMember::where('community_id', $communityId)
                ->where('doctor_id', $doctor->id)
                ->first();
        } else {
            $existingMember = CommunityMember::where('community_id', $communityId)
                ->where('patient_id', $patient->id)
                ->first();
        }
        
        if ($existingMember) {
            return response()->json([
                'message' => 'Already a member of this community'
            ], 400);
        }
        
        // إنشاء العضوية
        $memberData = [
            'community_id' => $communityId,
            'role' => 'member',
            'join_date' => now()
        ];
        
        if ($doctor) {
            $memberData['doctor_id'] = $doctor->id;
        } else {
            $memberData['patient_id'] = $patient->id;
        }
        
        $member = CommunityMember::create($memberData);
        
        return response()->json([
            'message' => 'Joined community successfully',
            'member' => $member
        ]);
    }
}
