<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth; // FIX: Pertahankan Auth facade ini

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// HAPUS: Rute-rute reset password manual yang kita tambahkan sebelumnya
// Route::get('password/reset', [ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
// Route::post('password/email', [ForgotPasswordController::class, 'sendResetLinkEmail'])->name('password.email');
// Route::get('password/reset/{token}', [ResetPasswordController::class, 'showResetForm'])->name('password.reset');
// Route::post('password/reset', [ResetPasswordController::class, 'reset'])->name('password.update');

Auth::routes(); // FIX: Ini mendaftarkan SEMUA rute autentikasi bawaan Laravel (login, register, reset password, email verification)

Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');