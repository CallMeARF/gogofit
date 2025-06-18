<?php

namespace App\Http\Controllers;

use App\Models\FoodLog;
use Illuminate\Http\Request;

class FoodLogController extends Controller
{
    public function index()
    {
        return FoodLog::with('food', 'user')->get();
    }

    public function store(Request $request)
{
    try {
        // Validasi input
        $validated = $request->validate([
            'food_id' => 'required|exists:foods,id',
            'quantity' => 'required|integer',
            'consumed_at' => 'required|date', // Validasi untuk consumed_at
        ]);

        // Buat entri log makanan baru
        $foodLog = FoodLog::create([
            'user_id' => auth()->id(), // Ambil ID pengguna yang terautentikasi
            'food_id' => $validated['food_id'],
            'quantity' => $validated['quantity'],
            'consumed_at' => $validated['consumed_at'],
        ]);

        return response()->json($foodLog, 201);
    } catch (\Illuminate\Validation\ValidationException $e) {
        // Tangani error validasi
        return response()->json([
            'message' => 'Validation failed',
            'errors' => $e->errors(),
        ], 422);
    } catch (\Exception $e) {
        // Tangani error lainnya
        return response()->json([
            'message' => 'An error occurred while creating the food log entry',
            'error' => $e->getMessage(),
        ], 500);
    }
}

}
