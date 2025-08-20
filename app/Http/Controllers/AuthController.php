<?php

namespace App\Http\Controllers;

use App\Models\Doctor;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\patient;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
{
    $request->validate([
        'name' => 'required|string',
        'email' => 'required|email|unique:users',
        'password' => 'required|string|min:8|confirmed',
        'role' => 'required|in:patient,doctor',
        'profile_picture' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
    ]);

    $profilePicturePath = null;
    if ($request->hasFile('profile_picture')) {
        $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
    }
    

    // إنشاء المستخدم الأساسي
    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'role' => $request->role,
        'is_approved' => $request->role === 'patient',
        'profile_picture' => $profilePicturePath,
    ]);

    // إنشاء السجل الخاص حسب الدور
    if ($request->role === 'patient') {
        $request->validate([
            'birth_date' => 'required|date',
            'gender' => 'required',
            'phone' => 'required|string'
        ]);

        Patient::create([
            'user_id' =>$user->id,
            'birth_date' => $request->birth_date,
            'gender' => $request->gender,
            'phone' => $request->phone,
            'chronic_diseases' => $request->chronic_diseases,
        ]);

    } 
    else {
        $request->validate([
            'specialization' => 'required|string',
            'clinic_address' => 'required|string',
            'clinic_phone' => 'required|string',
            'certificate_path' => 'required|file|mimes:jpg,png,pdf|max:2048'
        ]);

        $certificate_path = $request->file('certificate_path')->store('doctor_certificates', 'public');
        
        Doctor::create([
            'user_id' =>$user->id,
            'specialization' => $request->specialization,
            'clinic_address' => $request->clinic_address,
            'clinic_phone' => $request->clinic_phone,
            'certificate_path' => $certificate_path
        ]);
    }

    return response()->json(['message' => 'تم التسجيل بنجاح'], 201);
}

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['بيانات الاعتماد غير صحيحة'],
            ]);
        }

        if ($user->role === 'doctor') {
        $doctor = Doctor::where('user_id', $user->id)->first();
        
        if ($doctor->verification_status === 'rejected') {
            return response()->json([
                'message' => 'تم رفض شهادتك من قبل الإدارة',
                'is_approved' => false,
                'verification_status' => 'rejected'
            ], 403);
        }
        
        if ($doctor->verification_status !== 'approved') {
            return response()->json([
                'message' => 'في انتظار مراجعة شهادتك من قبل الإدارة',
                'is_approved' => false,
                'verification_status' => 'pending'
            ], 403);
        }


            return response()->json([
            'token' =>$user->createToken('auth_Token')->plainTextToken,
            'user' => $user,
            'doctor' => $doctor
        
        ]);
    }

        if ($user->role === 'patient') {
            $patient = Patient::where('user_id', $user->id)->first();

            return response()->json([
            'token' =>$user->createToken('auth_Token')->plainTextToken,
            'user' => $user,
            'patient' => $patient
        
        ]);
        }

        return response()->json([
            'token' =>$user->createToken('auth_Token')->plainTextToken,
            'user' => $user,
        
        ]);
    }
    
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'تم تسجيل الخروج']);
    }
}
