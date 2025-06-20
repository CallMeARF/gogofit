<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\FoodLog; // BARU: Import FoodLog model

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

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
    ];

    /**
     * Get the food logs for the user.
     */
    public function foodLogs()
    {
        return $this->hasMany(FoodLog::class);
    }
}
