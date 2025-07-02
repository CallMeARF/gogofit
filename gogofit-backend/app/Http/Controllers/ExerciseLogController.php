<?php

namespace App\Http\Controllers;

use App\Models\ExerciseLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ExerciseLogController extends Controller
{
    /**
     * Display a listing of the resource for a specific date.
     */
    public function index(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'date' => 'required|date_format:Y-m-d',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        // PERBAIKAN: Beri petunjuk tipe pada Intelephense
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        $exerciseLogs = $user->exerciseLogs()
            ->whereDate('exercised_at', $request->date)
            ->get();
        
        return response()->json(['success' => true, 'data' => $exerciseLogs]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'activity_name' => 'required|string|max:255',
            'duration_minutes' => 'required|integer|min:1',
            'calories_burned' => 'required|integer|min:1',
            'exercised_at' => 'required|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        // PERBAIKAN: Beri petunjuk tipe pada Intelephense
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $exerciseLog = $user->exerciseLogs()->create($validator->validated());

        return response()->json(['success' => true, 'message' => 'Log latihan berhasil ditambahkan.', 'data' => $exerciseLog], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(ExerciseLog $exerciseLog)
    {
        if ($exerciseLog->user_id !== Auth::id()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json(['success' => true, 'data' => $exerciseLog]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, ExerciseLog $exerciseLog)
    {
        if ($exerciseLog->user_id !== Auth::id()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'activity_name' => 'sometimes|required|string|max:255',
            'duration_minutes' => 'sometimes|required|integer|min:1',
            'calories_burned' => 'sometimes|required|integer|min:1',
            'exercised_at' => 'sometimes|required|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }
        
        $exerciseLog->update($validator->validated());

        return response()->json(['success' => true, 'message' => 'Log latihan berhasil diperbarui.', 'data' => $exerciseLog]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ExerciseLog $exerciseLog)
    {
        if ($exerciseLog->user_id !== Auth::id()) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $exerciseLog->delete();

        return response()->json(['success' => true, 'message' => 'Log latihan berhasil dihapus.'], 200);
    }
}