<?php

namespace App\Http\Controllers;
use App\Models\User;
use App\Models\patient;
use App\Models\Doctor;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
   // عرض الملف الشخصي
    public function show()
    {
        $user = Auth::user();
        
        $profileData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'profile_picture' => $user->profile_picture,
            'email_verified_at' => $user->email_verified_at,
            'is_approved' => $user->is_approved
        ];

        if ($user->role === 'patient') {
            $patient = Patient::where('user_id', $user->id)->first();
            return response()->json([
            'success' => true,
            'data' => $profileData,
            'patient' => $patient
        ]);
        } 

        elseif ($user->role === 'doctor') {
            $doctor = Doctor::where('user_id', $user->id)->first();
            return response()->json([
            'success' => true,
            'data' => $profileData,
            'doctor' => $doctor
        ]);
        }

        return response()->json([
            'success' => true,
            'data' => $profileData
        ]);
    }


    // تحديث الملف الشخصي
    public function update(Request $request)
    {
        $userId = Auth::id();
        $user = User::where('id', $userId)->first();
        
        // القواعد العامة
        /*$validationRules = [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'profile_picture' => 'sometimes|image|mimes:jpeg,png,jpg,gif|max:2048'
        ];

        // إضافة القواعد حسب الدور
        if ($user->role === 'patient') {
            $validationRules = array_merge($validationRules, [
                'birth_date' => 'sometimes|date',
                'gender' => 'sometimes|in:male,female,other',
                'phone' => 'sometimes|string|max:20',
                'chronic_diseases' => 'sometimes|string|nullable'
            ]);
        } 
        elseif ($user->role === 'doctor') {
            $validationRules = array_merge($validationRules, [
                'specialization' => 'sometimes|string|max:255',
                'clinic_address' => 'sometimes|string|max:500',
                'clinic_phone' => 'sometimes|string|max:20',
                'certificate' => 'sometimes|file|mimes:pdf,jpeg,png,jpg|max:5120'
            ]);
        }

        // التحقق من الصلاحية
        $request->validate($validationRules);*/

        // تحديث بيانات المستخدم الأساسية
        if ($request->has('name') || $request->has('email')) {
            $user->update([
                'name' => $request->name ?? $user->name,
                'email' => $request->email ?? $user->email
            ]);
        }

            if ($request->hasFile('profile_picture')) {
        if ($user->profile_picture) {
            
            if (file_exists(public_path('storage/' . $user->profile_picture))) {
                unlink(public_path('storage/' . $user->profile_picture));
            }
        }
        
        
        $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
        
        $user->profile_picture = $profilePicturePath;
        $user->save();
    }

        // تحديث البيانات حسب الدور
        if ($user->role === 'patient') {
            $patient = Patient::where('user_id', $user->id)->first();
            if ($patient) {
                $patient->update([
                    'birth_date' => $request->birth_date ?? $patient->birth_date,
                    'gender' => $request->gender ?? $patient->gender,
                    'phone' => $request->phone ?? $patient->phone,
                    'chronic_diseases' => $request->chronic_diseases ?? $patient->chronic_diseases
                ]);
            }
        } 
        elseif ($user->role === 'doctor') {
            $doctor = Doctor::where('user_id', $user->id)->first();
            if ($doctor) {
                $doctorData = [
                    'specialization' => $request->specialization ?? $doctor->specialization,
                    'clinic_address' => $request->clinic_address ?? $doctor->clinic_address,
                    'clinic_phone' => $request->clinic_phone ?? $doctor->clinic_phone
                ];
                
                $doctor->update($doctorData);
            }
        }

        // إعادة البيانات المحدثة
        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الملف الشخصي بنجاح',
            'data' => $this->getProfileData($user)
        ]);
    }

        private function getProfileData(User $user)
    {
        $profileData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'profile_picture' => $user->profile_picture,
            'email_verified_at' => $user->email_verified_at,
            'is_approved' => $user->is_approved
        ];

        if ($user->role === 'patient') {
            $patient = Patient::where('user_id', $user->id)->first();
            if ($patient) {
                $profileData['birth_date'] = $patient->birth_date;
                $profileData['gender'] = $patient->gender;
                $profileData['phone'] = $patient->phone;
                $profileData['chronic_diseases'] = $patient->chronic_diseases;
            }
        } 
        elseif ($user->role === 'doctor') {
            $doctor = Doctor::where('user_id', $user->id)->first();
            if ($doctor) {
                $profileData['specialization'] = $doctor->specialization;
                $profileData['clinic_address'] = $doctor->clinic_address;
                $profileData['clinic_phone'] = $doctor->clinic_phone;
                $profileData['certificate_path'] = $doctor->certificate_path;
                $profileData['verification_status'] = $doctor->verification_status;
                $profileData['rejection_reason'] = $doctor->rejection_reason;
            }
        }

        return $profileData;
    }
    // حذف الحساب
    public function destroy()
    {
        $userId = Auth::id();
        $user = User::where('id', $userId)->first();
        
        // حذف الصورة الشخصية إذا existed
        if ($user->profile_picture) {
            if (file_exists(public_path('storage/' . $user->profile_picture))) {
                unlink(public_path('storage/' . $user->profile_picture));
            }
        }

        // حذف البيانات حسب الدور
        if ($user->role === 'patient') {
            $patient = Patient::where('user_id', $user->id)->first();
            if ($patient) {
                $patient->delete();
            }
        } 
        elseif ($user->role === 'doctor') {
            $doctor = Doctor::where('user_id', $user->id)->first();
            if ($doctor) {
                // حذف شهادة الطبيب إذا existed
                if ($doctor->certificate_path && file_exists(public_path('storage/' . $doctor->certificate_path))) {
                    unlink(public_path('storage/' . $doctor->certificate_path));
                }
                $doctor->delete();
            }
        }

        // حذف المستخدم
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الحساب بنجاح'
        ]);
    }
}
