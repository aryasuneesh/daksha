plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "in.aryasuneesh.daksha"
    compileSdk = flutter.compileSdkVersion
    // Pin NDK r28: ensures `libapp.so` (Flutter AOT) is linked with
    // `--max-page-size=16384`. Inheriting via `flutter.ndkVersion` can pick a
    // pre-r27 toolchain depending on the local SDK manager state, leaving
    // LOAD segments aligned to 4 KB and unloadable on 16 KB-page devices.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
        }
    }

    defaultConfig {
        applicationId = "in.aryasuneesh.daksha"
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

    // Store .so files uncompressed so the OS can load them directly from the
    // APK with their original ELF alignment intact — required for 16 KB page
    // size compatibility on Android 15+ devices.
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}
