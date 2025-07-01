<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->date('birth_date')->nullable();
            $table->float('height')->nullable(); 
            $table->float('weight')->nullable(); 
            $table->float('target_weight')->nullable(); 
            // PERBAIKAN: Hapus 'other' dari enum goal
            $table->enum('goal', ['lose_weight', 'gain_weight', 'stay_healthy'])->nullable(); 
            $table->enum('activity_level', ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'super_active'])->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};