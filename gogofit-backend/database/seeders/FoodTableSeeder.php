<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Food;
use Illuminate\Support\Facades\DB;

class FoodTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('foods')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $foods = [
            [
                'name' => 'Nasi Goreng Ayam',
                'calories' => 350, 'protein' => 15, 'carbohydrates' => 45, 'fat' => 12, 'saturated_fat' => 3, 'sugar' => 5, 'image' => null,
            ],
            [
                'name' => 'Bakso Sapi Kuah (1 Mangkok)',
                'calories' => 300, 'protein' => 20, 'carbohydrates' => 25, 'fat' => 15, 'saturated_fat' => 6, 'sugar' => 3, 'image' => null,
            ],
            [
                'name' => 'Gado-Gado Saus Kacang',
                'calories' => 400, 'protein' => 15, 'carbohydrates' => 30, 'fat' => 25, 'saturated_fat' => 4, 'sugar' => 15, 'image' => null,
            ],
            [
                'name' => 'Sate Ayam (10 tusuk)',
                'calories' => 350, 'protein' => 30, 'carbohydrates' => 10, 'fat' => 20, 'saturated_fat' => 5, 'sugar' => 8, 'image' => null,
            ],
            [
                'name' => 'Ayam Goreng Paha Atas',
                'calories' => 280, 'protein' => 25, 'carbohydrates' => 5, 'fat' => 18, 'saturated_fat' => 5, 'sugar' => 0, 'image' => null,
            ],
            // PERBAIKAN: Menambahkan 5 data baru
            [
                'name' => 'Rendang Daging Sapi (1 potong)',
                'calories' => 450, 'protein' => 25, 'carbohydrates' => 8, 'fat' => 35, 'saturated_fat' => 16, 'sugar' => 4, 'image' => null,
            ],
            [
                'name' => 'Soto Ayam Lamongan',
                'calories' => 312, 'protein' => 22, 'carbohydrates' => 30, 'fat' => 12, 'saturated_fat' => 3, 'sugar' => 2, 'image' => null,
            ],
            [
                'name' => 'Ikan Bakar (1 ekor sedang)',
                'calories' => 250, 'protein' => 30, 'carbohydrates' => 5, 'fat' => 12, 'saturated_fat' => 2.5, 'sugar' => 3, 'image' => null,
            ],
            [
                'name' => 'Nasi Putih (1 piring)',
                'calories' => 205, 'protein' => 4.3, 'carbohydrates' => 45, 'fat' => 0.4, 'saturated_fat' => 0.1, 'sugar' => 0, 'image' => null,
            ],
            [
                'name' => 'Capcay Goreng Sayuran',
                'calories' => 180, 'protein' => 8, 'carbohydrates' => 20, 'fat' => 8, 'saturated_fat' => 1.5, 'sugar' => 7, 'image' => null,
            ],
        ];

        foreach ($foods as $food) {
            Food::create($food);
        }
    }
}