<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User; // FIX: Import User model secara eksplisit

class FoodLog extends Model
{
    use HasFactory;

    // FIX: Update $fillable untuk mencerminkan skema denormalisasi
    protected $fillable = [
        'user_id',
        'name',
        'calories',
        'fat',
        'saturated_fat',
        'carbohydrates',
        'protein',
        'sugar',
        'consumed_at',
        'meal_type',
    ];

    // FIX: Tambahkan $casts untuk tipe data yang benar
    protected $casts = [
        'calories' => 'float',
        'fat' => 'float',
        'saturated_fat' => 'float',
        'carbohydrates' => 'float',
        'protein' => 'float',
        'sugar' => 'float',
        'consumed_at' => 'datetime', // Cast sebagai datetime objek
    ];

    /**
     * Get the user that owns the food log.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // FIX: Hapus relasi `food()` karena `food_id` dan `quantity` tidak lagi ada di food_logs.
    // public function food()
    // {
    //      return $this->belongsTo(Food::class);
    // }
}