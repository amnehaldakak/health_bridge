<?php

namespace App\Http\Controllers;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\CommunityMember;
use App\Models\CommunityPost;
use App\Models\PostComment;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class PostCommentController extends Controller
{
        public function addComment(Request $request, $postId)
    {
        $request->validate([
            'contente' => 'required|string'
        ]);

        $userId = Auth::id();
        
        // التحقق إذا كان المستخدم طبيب أو مريض
        $doctor = Doctor::where('user_id', $userId)->first();
        $patient = Patient::where('user_id', $userId)->first();
        
        if (!$doctor && !$patient) {
            return response()->json([
                'message' => 'Only doctors or patients can add comments'
            ], 403);
        }
        
        // التحقق من وجود المنشور
        $post = CommunityPost::findOrFail($postId);
        
        // التحقق من أن المستخدم عضو في المجتمع
        $isMember = false;
        $communityId = $post->community_id;
        
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
                'message' => 'You must be a member of the community to add comments'
            ], 403);
        }
        
        // إنشاء التعليق
        $commentData = [
            'post_id' => $postId,
            'content' => $request->contente
        ];
        
        if ($doctor) {
            $commentData['doctor_id'] = $doctor->id;
        } else {
            $commentData['patient_id'] = $patient->id;
        }
        
        $comment = PostComment::create($commentData);

        return response()->json([
            'message' => 'Comment added successfully',
            'comment' => $comment
        ]);
    }

        public function getPostWithComments($postId)
    {
        $post = CommunityPost::with([
            'patient.user', 
            'doctor.user', 
            'comments' => function($query) {
                $query->with(['patient.user', 'doctor.user']);
            }
        ])->findOrFail($postId);

        return response()->json([
            'post' => $post
        ]);
    }
}
