<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user.
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'gender' => 'nullable|in:male,female', 
            'birth_date' => 'nullable|date',
            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric',
            'target_weight' => 'nullable|numeric',
            'goal' => 'nullable|in:lose_weight,gain_weight,stay_healthy', 
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'gender' => $request->gender, 
            'birth_date' => $request->birth_date,
            'height' => $request->height,
            'weight' => $request->weight,
            'target_weight' => $request->target_weight,
            'goal' => $request->goal, 
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'User registered successfully',
            'token' => $token,
            'user' => $this->mapUserToFlutterResponse($user), 
        ], 201);
    }

    /**
     * Authenticate the user.
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['Invalid credentials.'],
            ]);
        }

        /** @var \App\Models\User $user */
        $user = $request->user();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'user' => $this->mapUserToFlutterResponse($user), 
        ]);
    }

    /**
     * Update user profile.
     */
    public function updateProfile(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|string|email|max:255|unique:users,email,' . $user->id,
            'gender' => 'nullable|in:male,female', 
            'birth_date' => 'nullable|date',
            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric', 
            'target_weight' => 'nullable|numeric', 
            'goal' => 'nullable|in:lose_weight,gain_weight,stay_healthy', 
        ]);
        
        $user->fill($request->all());
        $user->save();

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $this->mapUserToFlutterResponse($user), 
        ]);
    }

    /**
     * Get authenticated user profile.
     */
    public function getProfile(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        return response()->json($this->mapUserToFlutterResponse($user));
    }

    // BARU: Metode untuk mengubah password pengguna
    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        /** @var \App\Models\User $user */
        $user = Auth::user();

        // Verifikasi password lama
        if (!Hash::check($request->old_password, $user->password)) {
            throw ValidationException::withMessages([
                'old_password' => ['Kata sandi lama tidak cocok.'],
            ]);
        }

        // Simpan password baru
        $user->password = Hash::make($request->new_password);
        $user->save();

        // Opsi: Revoke semua token sesi lama untuk keamanan
        // $user->tokens()->delete(); 

        return response()->json(['message' => 'Kata sandi berhasil diubah.']);
    }


    /**
     * Logout the user (revoke token).
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully']);
    }

    /**
     * Helper method to map User model attributes to Flutter UserProfile response format.
     * Mengembalikan nilai enum asli dari BE untuk gender dan goal.
     */
    protected function mapUserToFlutterResponse(User $user)
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'gender' => $user->gender, 
            'birth_date' => $user->birth_date ? $user->birth_date->toDateString() : null,
            'height' => $user->height,
            'weight' => $user->weight,
            'target_weight' => $user->target_weight,
            'goal' => $user->goal, 
        ];
    }
}
