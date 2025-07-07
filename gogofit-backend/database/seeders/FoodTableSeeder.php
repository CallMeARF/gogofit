<?php

namespace Database\Seeders;

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
                'name' => 'Crispy Chicken',
                'calories' => 255, 'protein' => 16, 'carbohydrates' => 15, 'fat' => 15, 'saturated_fat' => 4, 'sugar' => 0, 'image' => null,
            ],
            [
                'name' => 'Donut',
                'calories' => 250, 'protein' => 4, 'carbohydrates' => 30, 'fat' => 14, 'saturated_fat' => 5, 'sugar' => 12, 'image' => null,
            ],
            [
                'name' => 'French Fries',
                'calories' => 510, 'protein' => 7, 'carbohydrates' => 50, 'fat' => 30, 'saturated_fat' => 6, 'sugar' => 0, 'image' => null,
            ],
            [
                'name' => 'Gado-gado',
                'calories' => 350, 'protein' => 10, 'carbohydrates' => 25, 'fat' => 20, 'saturated_fat' => 4, 'sugar' => 8, 'image' => null,
            ],
            [
                'name' => 'Hotdog',
                'calories' => 275, 'protein' => 11, 'carbohydrates' => 20, 'fat' => 18, 'saturated_fat' => 7, 'sugar' => 4, 'image' => null,
            ],
            [
                'name' => 'Ikan Goreng',
                'calories' => 200, 'protein' => 20, 'carbohydrates' => 0, 'fat' => 12, 'saturated_fat' => 3, 'sugar' => 0, 'image' => null,
            ],
            [
                'name' => 'Mie Goreng',
                'calories' => 370, 'protein' => 7, 'carbohydrates' => 40, 'fat' => 18, 'saturated_fat' => 5, 'sugar' => 2, 'image' => null,
            ],
            [
                'name' => 'Nasi Padang',
                'calories' => 450, 'protein' => 20, 'carbohydrates' => 40, 'fat' => 25, 'saturated_fat' => 10, 'sugar' => 3, 'image' => null,
            ],
            [
                'name' => 'Pizza (1 slice)',
                'calories' => 285, 'protein' => 12, 'carbohydrates' => 33, 'fat' => 10, 'saturated_fat' => 4, 'sugar' => 3, 'image' => null,
            ],
            [
                'name' => 'Rawon',
                'calories' => 300, 'protein' => 18, 'carbohydrates' => 15, 'fat' => 20, 'saturated_fat' => 6, 'sugar' => 2, 'image' => null,
            ],
            [
                'name' => 'Rendang',
                'calories' => 450, 'protein' => 25, 'carbohydrates' => 8, 'fat' => 35, 'saturated_fat' => 16, 'sugar' => 2, 'image' => null,
            ],
            [
                'name' => 'Sandwich',
                'calories' => 300, 'protein' => 15, 'carbohydrates' => 35, 'fat' => 12, 'saturated_fat' => 5, 'sugar' => 5, 'image' => null,
            ],
            [
                'name' => 'Sate (5 tusuk)',
                'calories' => 250, 'protein' => 20, 'carbohydrates' => 10, 'fat' => 15, 'saturated_fat' => 4, 'sugar' => 3, 'image' => null,
            ],
            [
                'name' => 'Soto',
                'calories' => 200, 'protein' => 12, 'carbohydrates' => 10, 'fat' => 10, 'saturated_fat' => 3, 'sugar' => 1, 'image' => null,
            ],
            [
                'name' => 'Taco',
                'calories' => 170, 'protein' => 8, 'carbohydrates' => 15, 'fat' => 10, 'saturated_fat' => 4, 'sugar' => 1, 'image' => null,
            ],
            [
                'name' => 'Taquito',
                'calories' => 150, 'protein' => 7, 'carbohydrates' => 12, 'fat' => 8, 'saturated_fat' => 3, 'sugar' => 1, 'image' => null,
            ],
        ];

        foreach ($foods as $food) {
            Food::create($food);
        }
    }
}
