<?php

namespace App\Http\Controllers;

use App\Models\Food;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class FoodController extends Controller
{
    /**
     * Menampilkan daftar makanan dengan fitur pencarian dan paginasi.
     * Sekarang mendukung parameter 'query' untuk pencarian spesifik (dari ML).
     */
    public function index(Request $request)
    {
        // Ambil query pencarian dari request
        $searchQuery = $request->query('search'); // Untuk pencarian umum dengan paginasi
        $mlQuery = $request->query('query');     // BARU: Untuk pencarian dari hasil ML

        $foods = Food::query();

        if ($mlQuery) {
            // Jika ada parameter 'query' (dari hasil ML), lakukan pencarian spesifik
            $foods->where('name', 'like', "%{$mlQuery}%");
            // Tidak perlu paginasi untuk hasil ML, kembalikan langsung list
            return response()->json(['success' => true, 'data' => $foods->get()]);
        } else {
            // Jika tidak ada 'query' ML, gunakan 'search' dan paginasi seperti biasa
            $foods->when($searchQuery, function ($query, $search) {
                return $query->where('name', 'like', "%{$search}%");
            });

            $paginatedFoods = $foods->paginate(10); // Terapkan paginasi, 10 item per halaman
            return response()->json(['success' => true, 'data' => $paginatedFoods]);
        }
    }


    /**
     * Menyimpan makanan baru ke dalam database.
     */
    public function store(Request $request)
    {
        // Validasi input disederhanakan, Laravel akan handle response error otomatis
        $validatedData = $request->validate([
            'name' => 'required|string|max:255|unique:foods,name',
            'calories' => 'required|numeric|min:0',
            'sugar' => 'required|numeric|min:0',
            'protein' => 'required|numeric|min:0',
            'carbohydrates' => 'required|numeric|min:0',
            'fat' => 'required|numeric|min:0',
            'saturated_fat' => 'required|numeric|min:0',
            'image' => 'nullable|string', // Untuk saat ini kita simpan URL sebagai string
        ]);

        $food = Food::create($validatedData);

        return response()->json(['success' => true, 'message' => 'Makanan berhasil ditambahkan.', 'data' => $food], 201);
    }

    /**
     * Menampilkan detail satu makanan.
     * Menggunakan Route Model Binding.
     */
    public function show(Food $food)
    {
        return response()->json(['success' => true, 'data' => $food]);
    }

    /**
     * Memperbarui data makanan yang ada.
     * Menggunakan Route Model Binding.
     */
    public function update(Request $request, Food $food)
    {
        $validatedData = $request->validate([
            // 'sometimes' berarti validasi hanya dilakukan jika field tersebut ada di request
            'name' => 'sometimes|required|string|max:255|unique:foods,name,' . $food->id,
            'calories' => 'sometimes|required|numeric|min:0',
            'sugar' => 'sometimes|required|numeric|min:0',
            'protein' => 'sometimes|required|numeric|min:0',
            'carbohydrates' => 'sometimes|required|numeric|min:0',
            'fat' => 'sometimes|required|numeric|min:0',
            'saturated_fat' => 'sometimes|required|numeric|min:0',
            'image' => 'nullable|string',
        ]);

        $food->update($validatedData);

        return response()->json(['success' => true, 'message' => 'Makanan berhasil diperbarui.', 'data' => $food]);
    }

    /**
     * Menghapus data makanan dari database.
     * Menggunakan Route Model Binding.
     */
    public function destroy(Food $food)
    {
        $food->delete();
        
        return response()->json(['success' => true, 'message' => 'Makanan berhasil dihapus.']);
    }
}