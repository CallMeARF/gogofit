<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExerciseLog extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'activity_name',
        'duration_minutes',
        'calories_burned',
        'exercised_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'exercised_at' => 'datetime',
    ];

    /**
     * Get the user that owns the exercise log.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}