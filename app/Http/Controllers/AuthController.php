<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\DoctorVerification;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        /*$data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
            'role' => 'required|in:patient,doctor',
            'license_number' => 'required_if:role,doctor|string|unique:doctor_verifications',
            'certificate' => 'required_if:role,doctor|file|mimes:jpg,png,pdf|max:2048'
        ]);*/

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'is_approved' => $request->role === 'patient' // يقبل المرضى تلقائيًا
        ]); 

        return response()->json(['message' => 'تم التسجيل بنجاح'], 201);
    }

    public function login(Request $request)
    {
        /*$request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required'
        ]);*/

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['بيانات الاعتماد غير صحيحة'],
            ]);
        }

        return response()->json([
            'token' => $user->createToken($request->device_name)->plainTextToken,
            //'user' => $user->load('doctorVerification')
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'تم تسجيل الخروج']);
    }
}
