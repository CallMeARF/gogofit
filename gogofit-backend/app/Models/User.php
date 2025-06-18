<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

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
        'target_weight', // BARU: Tambahkan kolom ini ke fillable
        'goal',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'birth_date' => 'date',
        'height' => 'float', // BARU: Cast sebagai float
        'weight' => 'float', // BARU: Cast sebagai float
        'target_weight' => 'float', // BARU: Cast sebagai float
    ];
}
