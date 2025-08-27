<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DoctorApprovalController;
use App\Http\Controllers\MedicalCaseController;
use App\Http\Controllers\ApprovalController;
use App\Http\Controllers\MedicationGroupController;
use App\Http\Controllers\MedicationController;
use App\Http\Controllers\ReminderController;
use App\Http\Controllers\PatientMedicationController;
use App\Http\Controllers\HealthyValueController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


//Route::post('/register', [AuthController::class, 'register']);
//Route::post('/login', [AuthController::class, 'login']);


Route::controller(AuthController::class)->group(function () {
    Route::Post('register','register');
    Route::Post('login','login');
    Route::get('logout','logout')->middleware('auth:sanctum');

});

Route::controller(DoctorApprovalController::class)->group(function () {

    Route::get('pendingDoctors','pendingDoctors');
    Route::Post('showCertificate/{id}','showCertificate');
    Route::Post('approveDoctor/{id}','approveDoctor');
})->middleware('isAdmin');


Route::controller(MedicalCaseController::class)->group(function () {

    Route::Post('store','store')->middleware('auth:sanctum');
    Route::Post('updateMedicalCase/{case_id}','update')->middleware('auth:sanctum');
    Route::get('getDoctorPatients','getDoctorPatients')->middleware('auth:sanctum');
    Route::get('getPatientCasesByCurrentDoctor/{id}','getPatientCasesByCurrentDoctor')->middleware('auth:sanctum');
    Route::get('getPatientCases/{id}','getPatientCases');
    Route::get('show/{id}','show');
});

Route::controller(ApprovalController::class)->group(function () {

    Route::get('pendingApprovals','pendingApprovals')->middleware('auth:sanctum');
    Route::Post('approve/{id}','approve')->middleware('auth:sanctum');
    Route::Post('reject/{id}','reject')->middleware('auth:sanctum');
});

Route::controller(MedicationGroupController::class)->group(function () {

    Route::Post('storeMedicationGroup/{id}','store')->middleware('auth:sanctum');
    Route::get('showMedicationGroup/{id}','show');
    Route::get('destroy/{id}','destroy');
});

Route::controller(MedicationController::class)->group(function () {

    Route::Post('confirmMedication/{id}','confirmMedication')->middleware('auth:sanctum');
    Route::Post('updateMedication/{id}','update');
    Route::get('destroyMedication/{id}','destroy');
});

Route::controller(ReminderController::class)->group(function () {

    Route::Post('updateStatus/{id}','updateStatus');
    Route::get('getPatientReminders','getPatientReminders')->middleware('auth:sanctum');
});

Route::controller(PatientMedicationController::class)->group(function () {

    Route::Post('storePatientMedication','store')->middleware('auth:sanctum');
    Route::get('index','index')->middleware('auth:sanctum');
});

Route::controller(HealthyValueController::class)->group(function () {

    Route::Post('store_value/{id}','store_value')->middleware('auth:sanctum');
    Route::get('show_value/{id}','show_value')->middleware('auth:sanctum');
    Route::get('delete_value/{id}','delete_value');
    
});