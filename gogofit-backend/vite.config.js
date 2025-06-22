import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";

export default defineConfig({
    plugins: [
        laravel({
            input: [
                "resources/css/app.css", // Pastikan ini 'css' bukan 'sass'
                "resources/js/app.js",
            ],
            refresh: true,
        }),
    ],
    server: {
        host: "0.0.0.0",
        port: 5173,
        hmr: {
            host: "10.0.2.2",
            clientPort: 5173,
        },
        origin: "http://10.0.2.2:5173", // Penting untuk URL aset
        cors: true, // FIX: Tambahkan baris ini untuk mengaktifkan CORS
    },
});
