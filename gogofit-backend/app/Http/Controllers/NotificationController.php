<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index()
    {
        // Mengambil notifikasi untuk pengguna yang terautentikasi
        return auth()->user()->unreadNotifications;
    }

    public function markAsRead($id)
    {
        // Mengambil notifikasi berdasarkan ID dan menandainya sebagai dibaca
        $notification = auth()->user()->notifications->where('id', $id)->first();
        
        if ($notification) {
            $notification->markAsRead();
            return response()->json(['message' => 'Notification marked as read']);
        }

        return response()->json(['message' => 'Notification not found'], 404);
    }
}
