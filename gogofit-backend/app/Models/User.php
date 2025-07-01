<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\FoodLog;
use Illuminate\Auth\Passwords\CanResetPassword; // BARU: Import CanResetPassword trait

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, CanResetPassword; // BARU: Tambahkan CanResetPassword

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
        'activity_level', // BARU: Tambahkan activity_level ke fillable
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
        'activity_level' => 'string', // BARU: Tambahkan activity_level ke casts
    ];

    /**
     * Get the food logs for the user.
     */
    public function foodLogs()
    {
        return $this->hasMany(FoodLog::class);
    }
}