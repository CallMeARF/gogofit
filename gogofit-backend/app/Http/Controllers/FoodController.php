<?php

namespace App\Http\Controllers;

use App\Models\Food;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    public function index()
    {
        return Food::all();
    }

    public function store(Request $request)
    {
        try {
            // Validasi input termasuk kolom baru
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'calories' => 'required|integer',
                'sugar' => 'required|integer',
                'protein' => 'nullable|numeric', // Tambahkan validasi untuk protein
                'carbohydrates' => 'nullable|numeric', // Tambahkan validasi untuk carbohydrates
                'fat' => 'nullable|numeric', // Tambahkan validasi untuk fat
                'image' => 'nullable|string', // Tambahkan validasi untuk image
            ]);

            // Buat entri makanan baru
            $food = Food::create($validated);

            // Kembalikan respons sukses
            return response()->json($food, 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            // Tangani error validasi
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            // Tangani error lainnya
            return response()->json([
                'message' => 'An error occurred while creating the food entry',
                'error' => $e->getMessage(),
            ], 500);
        }
    }


    public function show($id)
    {
        return Food::findOrFail($id);
    }

    public function update(Request $request, $id)
    {
        $food = Food::findOrFail($id);
        
        // Validasi input untuk update
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'calories' => 'sometimes|required|integer',
            'sugar' => 'sometimes|required|integer',
            'protein' => 'nullable|numeric',
            'carbohydrates' => 'nullable|numeric',
            'fat' => 'nullable|numeric',
            'image' => 'nullable|string',
        ]);

        // Update entri makanan
        $food->update($validated);
        return response()->json($food, 200);
    }

    public function destroy($id)
    {
        Food::destroy($id);
        return response()->json(null, 204);
    }
}
