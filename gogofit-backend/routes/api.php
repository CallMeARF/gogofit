<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\FoodController;
use App\Http\Controllers\FoodLogController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ExerciseLogController; // PERBAIKAN 1: Import controller baru

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Rute untuk autentikasi (Login, Register, Logout, dan Change Password)
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::post('/change-password', [AuthController::class, 'changePassword'])->middleware('auth:sanctum');
});

// Rute yang memerlukan autentikasi (untuk pengguna yang sudah login)
Route::middleware('auth:sanctum')->group(function () {
    // Rute untuk manajemen profil pengguna
    Route::get('/user/profile', [AuthController::class, 'getProfile']);
    Route::post('/update-profile', [AuthController::class, 'updateProfile']);

    // Rute untuk makanan (Foods master list - jika digunakan)
    Route::apiResource('/foods', FoodController::class);
    
    // Rute untuk log makanan
    Route::apiResource('/food-logs', FoodLogController::class);

    // PERBAIKAN 2: Tambahkan rute untuk log latihan
    Route::apiResource('/exercise-logs', ExerciseLogController::class);

    // Rute untuk notifikasi
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/mark-as-read', [NotificationController::class, 'markAsRead']);
});