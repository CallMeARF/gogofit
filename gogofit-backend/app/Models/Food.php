<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Food extends Model
{
    use HasFactory;

    protected $table = 'foods';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'calories',
        'sugar',
        'protein',
        'carbohydrates',
        'fat',
        'saturated_fat', // PERBAIKAN 1: Tambahkan saturated_fat
        'image',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [ // PERBAIKAN 2: Tambahkan casts untuk konsistensi tipe data
        'calories' => 'float',
        'sugar' => 'float',
        'protein' => 'float',
        'carbohydrates' => 'float',
        'fat' => 'float',
        'saturated_fat' => 'float',
    ];
}