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
        Schema::create('food_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // DIHAPUS: food_id dan quantity dihapus untuk menyimpan detail makanan langsung di log
            // Ini menyederhanakan integrasi dengan model MealEntry Flutter yang lengkap per entri log.
            // $table->foreignId('food_id')->constrained('foods')->onDelete('cascade');
            // $table->integer('quantity');

            // BARU: Kolom-kolom detail nutrisi langsung dari MealEntry Flutter
            $table->string('name');
            $table->float('calories')->nullable();
            $table->float('fat')->nullable();
            $table->float('saturated_fat')->nullable(); // Sesuai dengan field baru di FE
            $table->float('carbohydrates')->nullable();
            $table->float('protein')->nullable();
            $table->float('sugar')->nullable();
            $table->string('meal_type')->nullable(); // Untuk Sarapan, Makan Siang, dll.

            $table->timestamp('consumed_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('food_logs');
    }
};
