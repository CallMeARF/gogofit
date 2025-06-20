<?php

namespace App\Http\Controllers;

use App\Models\FoodLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Carbon\Carbon; 
use Illuminate\Support\Facades\Log; // FIX: Tambahkan baris ini untuk Intelephense

class FoodLogController extends Controller
{
    /**
     * Display a listing of the food logs for the authenticated user, optionally filtered by date.
     */
    public function index(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $query = $user->foodLogs(); 

        // Filter berdasarkan tanggal jika ada parameter 'date'
        if ($request->has('date')) {
            try {
                $request->validate([
                    'date' => 'date_format:Y-m-d',
                ]);
                $query->whereDate('consumed_at', $request->date);
            } catch (ValidationException $e) {
                return response()->json([
                    'message' => 'Invalid date format. Expected YYYY-MM-DD.',
                    'errors' => $e->errors(),
                ], 400); // Bad Request for invalid date format
            }
        } else {
            // Default: ambil log untuk hari ini jika tidak ada tanggal spesifik
            $query->whereDate('consumed_at', now()->toDateString());
        }

        // Urutkan berdasarkan waktu konsumsi (atau sesuai kebutuhan FE)
        $foodLogs = $query->orderBy('consumed_at', 'asc')->get();

        return response()->json([
            'message' => 'Food logs retrieved successfully',
            'data' => $foodLogs,
        ]);
    }

    /**
     * Store a newly created food log entry in storage.
     */
    public function store(Request $request)
    {
        try {
            // Validasi input berdasarkan skema denormalisasi food_logs
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'calories' => 'required|numeric',
                'fat' => 'required|numeric',
                'saturated_fat' => 'nullable|numeric',
                'carbohydrates' => 'required|numeric',
                'protein' => 'required|numeric',
                'sugar' => 'required|numeric',
                'consumed_at' => 'required|date', 
                'meal_type' => 'required|string|max:255', // e.g., 'Sarapan', 'Makan Siang'
            ]);

            /** @var \App\Models\User $user */
            $user = Auth::user();

            // Buat entri log makanan baru
            $foodLog = $user->foodLogs()->create([ // Gunakan relasi user
                'name' => $validated['name'],
                'calories' => $validated['calories'],
                'fat' => $validated['fat'],
                'saturated_fat' => $validated['saturated_fat'] ?? 0.0, // Default 0.0 jika null
                'carbohydrates' => $validated['carbohydrates'],
                'protein' => $validated['protein'],
                'sugar' => $validated['sugar'],
                'consumed_at' => Carbon::parse($validated['consumed_at']), 
                'meal_type' => $validated['meal_type'],
            ]);

            return response()->json([
                'message' => 'Food log entry created successfully',
                'data' => $foodLog, // Mengembalikan objek FoodLog yang sudah memiliki ID
            ], 201); // 201 Created
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422); // Unprocessable Entity
        } catch (\Exception $e) {
            Log::error("Error creating food log: " . $e->getMessage(), ['trace' => $e->getTraceAsString()]); // FIX: Menggunakan Log::
            return response()->json([
                'message' => 'An error occurred while creating the food log entry',
                'error' => $e->getMessage(),
            ], 500); // Internal Server Error
        }
    }

    /**
     * Display the specified food log entry.
     */
    public function show(FoodLog $foodLog)
    {
        // Pastikan food log milik user yang terautentikasi
        if (Auth::id() !== $foodLog->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'message' => 'Food log retrieved successfully',
            'data' => $foodLog,
        ]);
    }

    /**
     * Update the specified food log entry in storage.
     */
    public function update(Request $request, FoodLog $foodLog)
    {
        // Pastikan food log milik user yang terautentikasi
        if (Auth::id() !== $foodLog->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        try {
            // Validasi input
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'calories' => 'required|numeric',
                'fat' => 'required|numeric',
                'saturated_fat' => 'nullable|numeric',
                'carbohydrates' => 'required|numeric',
                'protein' => 'required|numeric',
                'sugar' => 'required|numeric',
                'consumed_at' => 'required|date',
                'meal_type' => 'required|string|max:255',
            ]);

            $foodLog->update([
                'name' => $validated['name'],
                'calories' => $validated['calories'],
                'fat' => $validated['fat'],
                'saturated_fat' => $validated['saturated_fat'] ?? 0.0,
                'carbohydrates' => $validated['carbohydrates'],
                'protein' => $validated['protein'],
                'sugar' => $validated['sugar'],
                'consumed_at' => Carbon::parse($validated['consumed_at']),
                'meal_type' => $validated['meal_type'],
            ]);

            return response()->json([
                'message' => 'Food log updated successfully',
                'data' => $foodLog, // Mengembalikan objek FoodLog yang sudah diupdate
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error("Error updating food log: " . $e->getMessage(), ['trace' => $e->getTraceAsString()]); // FIX: Menggunakan Log::
            return response()->json([
                'message' => 'An error occurred while updating the food log entry',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified food log entry from storage.
     */
    public function destroy(FoodLog $foodLog)
    {
        // Pastikan food log milik user yang terautentikasi
        if (Auth::id() !== $foodLog->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        try {
            $foodLog->delete();
            return response()->json(['message' => 'Food log deleted successfully']);
        } catch (\Exception $e) {
            Log::error("Error deleting food log: " . $e->getMessage(), ['trace' => $e->getTraceAsString()]); // FIX: Menggunakan Log::
            return response()->json([
                'message' => 'An error occurred while deleting the food log entry',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}