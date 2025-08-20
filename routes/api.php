<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DoctorApprovalController;
use App\Http\Controllers\MedicalCaseController;
use App\Http\Controllers\ApprovalController;

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
    Route::Post('update/{case_id}','update')->middleware('auth:sanctum');
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