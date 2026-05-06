plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cleaningtracker.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // If you fork this project, change applicationId to a unique ID you control,
        // then create a *new* Android OAuth client in your own Google Cloud project
        // (the existing client is bound to com.cleaningtracker.app + this repo's signing
        // keys and will reject your build). See docs/DEVELOPMENT.md §4.2.
        applicationId = "com.cleaningtracker.app"
        minSdk = flutter.minSdkVersion // Desugaring works better with explicit minSdk >= 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Release builds currently sign with the debug keystore so `flutter build apk
            // --release` works out of the box for contributors. Replace this with a real
            // signing config before publishing — see RELEASE.md.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
