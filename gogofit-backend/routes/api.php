<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\FoodController;
use App\Http\Controllers\FoodLogController;
use App\Http\Controllers\NotificationController;

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
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    // BARU: Tambahkan rute untuk mengubah password
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

    // Rute untuk notifikasi
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/mark-as-read', [NotificationController::class, 'markAsRead']);
});
