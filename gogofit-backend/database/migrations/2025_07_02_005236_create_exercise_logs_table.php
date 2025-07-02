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
        Schema::create('exercise_logs', function (Blueprint $table) {
            $table->id();

            // PERBAIKAN: Tambahkan kolom-kolom yang diperlukan untuk log latihan.
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('activity_name');
            $table->unsignedInteger('duration_minutes');
            $table->unsignedInteger('calories_burned');
            $table->timestamp('exercised_at');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exercise_logs');
    }
};