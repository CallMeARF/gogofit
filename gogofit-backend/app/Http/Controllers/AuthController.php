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
            // FIX: Kembalikan validasi ke 'in:' untuk enum
            'gender' => 'nullable|in:male,female', 
            'birth_date' => 'nullable|date',
            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric',
            'target_weight' => 'nullable|numeric',
            // FIX: Kembalikan validasi ke 'in:' untuk enum
            'goal' => 'nullable|in:lose_weight,gain_weight,stay_healthy', 
        ]);

        // DIHAPUS: Pemetaan $beGender dan $beGoal karena sudah dilakukan di Flutter (api_service.dart)
        // $beGender = null;
        // if ($request->gender == 'Laki-laki') { $beGender = 'male'; } elseif ($request->gender == 'Perempuan') { $beGender = 'female'; }
        // $beGoal = null;
        // if ($request->goal == 'Menurunkan Berat Badan') { $beGoal = 'lose_weight'; } elseif ($request->goal == 'Menaikkan Berat Badan') { $beGoal = 'gain_weight'; } elseif ($request->goal == 'Menjaga Kesehatan') { $beGoal = 'stay_healthy'; }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'gender' => $request->gender, // FIX: Gunakan langsung $request->gender (sudah BE string dari Flutter)
            'birth_date' => $request->birth_date,
            'height' => $request->height,
            'weight' => $request->weight,
            'target_weight' => $request->target_weight,
            'goal' => $request->goal, // FIX: Gunakan langsung $request->goal (sudah BE string dari Flutter)
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
            // FIX: Kembalikan validasi ke 'in:' untuk enum
            'gender' => 'nullable|in:male,female', 
            'birth_date' => 'nullable|date',
            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric', 
            'target_weight' => 'nullable|numeric', 
            // FIX: Kembalikan validasi ke 'in:' untuk enum
            'goal' => 'nullable|in:lose_weight,gain_weight,stay_healthy', 
        ]);

        // DIHAPUS: Pemetaan $beGender dan $beGoal karena sudah dilakukan di Flutter (api_service.dart)
        // $beGender = null;
        // if ($request->gender == 'Laki-laki') { $beGender = 'male'; } elseif ($request->gender == 'Perempuan') { $beGender = 'female'; }
        // $beGoal = null;
        // if ($request->goal == 'Menurunkan Berat Badan') { $beGoal = 'lose_weight'; } elseif ($request->goal == 'Menaikkan Berat Badan') { $beGoal = 'gain_weight'; } elseif ($request->goal == 'Menjaga Kesehatan') { $beGoal = 'stay_healthy'; }
        
        // $user->fill($request->except(['gender', 'goal'])); // Fill yang lain dulu (gender dan goal tidak perlu di-exclude lagi)
        // $user->gender = $beGender; // Set gender secara manual
        // $user->goal = $beGoal; // Set goal secara manual

        // FIX: Gunakan fill dengan $request->all() karena request sudah berisi string BE yang benar
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
        // Mengembalikan nilai asli dari database untuk gender dan goal
        // Pemetaan ke Bahasa Indonesia akan dilakukan di Flutter (UserProfile.fromJson)
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
