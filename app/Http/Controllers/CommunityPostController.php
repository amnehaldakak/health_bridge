<?php

namespace App\Http\Controllers;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Community;
use App\Models\CommunityMember;
use App\Models\CommunityPost;
use App\Models\MedicalCase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class CommunityPostController extends Controller
{
        public function addPost(Request $request, $communityId)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'contente' => 'required|string',
            //'case_id' => 'nullable|exists:medical_cases,id'
        ]);

        $userId = Auth::id();
        
        // التحقق إذا كان المستخدم طبيب أو مريض
        $doctor = Doctor::where('user_id', $userId)->first();
        $patient = Patient::where('user_id', $userId)->first();
        
        if (!$doctor && !$patient) {
            return response()->json([
                'message' => 'Only doctors or patients can create posts'
            ], 403);
        }
        
        // التحقق من أن المستخدم عضو في المجتمع
        $isMember = false;
        
        if ($doctor) {
            $isMember = CommunityMember::where('community_id', $communityId)
                ->where('doctor_id', $doctor->id)
                ->exists();
        } else {
            $isMember = CommunityMember::where('community_id', $communityId)
                ->where('patient_id', $patient->id)
                ->exists();
        }
        
        if (!$isMember) {
            return response()->json([
                'message' => 'You must be a member of the community to create posts'
            ], 403);
        }
        
        // إنشاء المنشور
        $postData = [
            'community_id' => $communityId,
            'case_id' => $request->case_id,
            'title' => $request->title,
            'content' => $request->contente,
            'is_public' => $request->is_public ?? true
        ];
        
        if ($doctor) {
            $postData['doctor_id'] = $doctor->id;
        } else {
            $postData['patient_id'] = $patient->id;
        }
        
        $post = CommunityPost::create($postData);

        return response()->json([
            'message' => 'Post created successfully',
            'post' => $post
        ]);
    }

        public function getCommunityDetails($communityId)
    {
        $community = Community::with(['posts.patient.user', 'posts.doctor.user'])
        ->findOrFail($communityId);

        return response()->json([
            'community' => $community
        ]);
    }

        public function shareMedicalCase(Request $request, $caseId, $communityId)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'contente' => 'required|string',
            'include_treatment_plan' => 'boolean'
        ]);

        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();
        // التحقق من أن المستخدم طبيب
    if (!$doctor) {
        return response()->json([
            'message' => 'Only doctors can share medical cases'
        ], 403);
    }

        // جلب الحالة مع العلاقات
        $case = MedicalCase::with([
            'patient:id,user_id,birth_date,gender,chronic_diseases',  
            'doctor.user',
            'medicationGroups.medications'
        ])->where('id', $caseId)
        ->where('doctor_id', $doctor->id)
        ->firstOrFail();

        // إنشاء المنشور
        $post = CommunityPost::create([
            'community_id' => $communityId,
            'doctor_id' => $doctor->id,
            'case_id' => $caseId,
            'title' => $request->title,
            'content' => $request->contente
        ]);


        return response()->json([
            'message' => 'Medical case shared successfully',
            'post' => $post,
            'medical_case' => $case,
        ]);
    }
}
