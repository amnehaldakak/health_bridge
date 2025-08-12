<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DoctorApprovalController;

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