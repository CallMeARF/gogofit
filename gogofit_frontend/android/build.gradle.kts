// android/build.gradle.kts
import org.gradle.api.initialization.resolve.RepositoriesMode
import org.gradle.api.file.Directory

plugins {
    id("com.android.application") version "8.7.0" apply false
    // Mengubah versi Kotlin ke 1.8.22 sesuai dengan error yang muncul
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false 
    id("dev.flutter.flutter-gradle-plugin") apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
