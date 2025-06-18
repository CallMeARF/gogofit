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
        Schema::create('foods', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            // UBAH: calories dari integer menjadi float
            $table->float('calories')->nullable();
            // UBAH: sugar dari integer menjadi float
            $table->float('sugar')->nullable();
            $table->float('protein')->nullable();
            $table->float('carbohydrates')->nullable();
            $table->float('fat')->nullable();
            // BARU: saturated_fat dengan tipe float
            $table->float('saturated_fat')->nullable(); 
            $table->string('image')->nullable(); // Jika ini untuk URL gambar
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('foods');
    }
};
