// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Repositories untuk dependensi proyek
// Ini harus berada di level atas file build.gradle.kts
// agar Gradle dapat menemukan semua dependensi, termasuk desugar_jdk_libs.
repositories {
    google() // Repositori Google, penting untuk Android Libraries
    mavenCentral() // Repositori Maven Central, banyak library umum ada di sini
}

android {
    namespace = "com.example.gogofit_frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Mengatur kompatibilitas sumber dan target Java ke versi 17.
        // Ini sesuai dengan JDK 17 yang sekarang Anda gunakan.
        sourceCompatibility = JavaVersion.VERSION_17 // <-- DIUBAH DARI 12
        targetCompatibility = JavaVersion.VERSION_17 // <-- DIUBAH DARI 12
        isCoreLibraryDesugaringEnabled = true // Memungkinkan penggunaan fitur Java 8+ pada Android versi lebih lama
    }

    kotlinOptions {
        // Mengatur jvmTarget untuk Kotlin ke versi 17, agar sesuai dengan konfigurasi Java.
        jvmTarget = JavaVersion.VERSION_17.toString() // <-- DIUBAH DARI 12
    }

    defaultConfig {
        applicationId = "com.example.gogofit_frontend"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // PERBAIKAN SINTAKS UNTUK KOTLIN DSL (.kts)
    aaptOptions {
        noCompress.add("tflite") // Menggunakan .add() untuk List
        noCompress.add("lite")   // Menggunakan .add() untuk List
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependensi untuk desugaring library, agar fitur Java 8+ dapat digunakan
    // pada versi Android yang lebih lama, bahkan saat menggunakan JDK 17+.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}