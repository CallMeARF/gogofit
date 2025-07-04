<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\FoodLog;
use App\Models\ExerciseLog; // PERBAIKAN 1: Import model ExerciseLog
use Illuminate\Auth\Passwords\CanResetPassword;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, CanResetPassword;

    protected $fillable = [
        'name',
        'email',
        'password',
        'gender',
        'birth_date',
        'height',
        'weight',
        'target_weight',
        'goal',
        'activity_level',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'birth_date' => 'date',
        'height' => 'float',
        'weight' => 'float',
        'target_weight' => 'float',
        'activity_level' => 'string',
    ];

    /**
     * Get the food logs for the user.
     */
    public function foodLogs()
    {
        return $this->hasMany(FoodLog::class);
    }

    /**
     * PERBAIKAN 2: Tambahkan relasi untuk log latihan.
     * Get the exercise logs for the user.
     */
    public function exerciseLogs()
    {
        return $this->hasMany(ExerciseLog::class);
    }
}