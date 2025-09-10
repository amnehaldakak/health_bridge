<?php

namespace App\Http\Controllers;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Community;
use App\Models\CommunityMember;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class CommunityController extends Controller
{
        public function createCommunity(Request $request)
    {
        $request->validate([
            'name' => 'required|string|unique:communities|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:private,public',
            'specialization' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('community_images', 'public');
        }

        $community = Community::create([
            'name' => $request->name,
            'description' => $request->description,
            'type' => $request->type,
            'specialization' => $request->specialization,
            'doctor_id' => $doctor->id,
            'is_private' => $request->type === 'private',
            'image' => $imagePath
        ]);

        CommunityMember::create([
        'community_id' => $community->id,
        'doctor_id' => $doctor->id,
        'role' => 'admin',
        'join_date' => now()
    ]);


        return response()->json([
            'message' => 'Community created successfully',
            'community' => $community
        ]);
    }

        public function updateCommunity(Request $request, $communityId)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'type' => 'sometimes|in:private,public',
            'specialization' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();

        $community = Community::where('id', $communityId)
            ->where('doctor_id', $doctor->id)
            ->firstOrFail();

        /*$isAdmin = CommunityMember::where('community_id', $communityId)
        ->where('doctor_id', $doctor->id)
        ->where('role', 'admin')
        ->exists();

        if (!$isAdmin) {
            return response()->json([
                'message' => 'Unauthorized: Only community admins can update the community'
            ], 403);
        }*/

        // تحديث الصورة إذا وجدت
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('community_images', 'public');
            $community->image = $imagePath;
        }

        $community->update($request->only(['name', 'description', 'type', 'specialization']));

        $community->save();


        return response()->json([
            'message' => 'Community updated successfully',
            'community' => $community
        ]);
    }


        public function getAllCommunities()
    {
        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();

        $communities = Community::with(['members' => function($query) use ($doctor) {
            $query->where('doctor_id', $doctor->id);
        }])
        ->get()
        ->map(function($community) {
            $community->is_member = $community->members->isNotEmpty();
            unset($community->members);
            $community->image = $community->image ? url('storage/' . $community->image) : null;
            return $community;
        });

        return response()->json([
            'communities' => $communities
        ]);
    }

        public function getPublicCommunities()
    {
        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();

        $communities = Community::where('type', 'public')
            ->with(['members' => function($query) use ($patient) {
                $query->where('patient_id', $patient->id);
            }])
            ->get()
            ->map(function($community) {
                $community->is_member = $community->members->isNotEmpty();
                unset($community->members);
                return $community;
            });

        return response()->json([
            'communities' => $communities
        ]);
    }
}
