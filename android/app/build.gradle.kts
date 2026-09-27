import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
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

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
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
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

configurations.all {
    resolutionStrategy {
        // Pin AndroidX test versions so the integration_test plugin and our
        // androidTest dependencies agree (otherwise Gradle picks newer
        // transitive versions and the FlutterTestRunner fails to load).
        force("androidx.test:runner:1.5.2")
        force("androidx.test:rules:1.5.0")
        force("androidx.test:core:1.5.0")
        force("androidx.test:monitor:1.6.1")
        force("androidx.test.ext:junit:1.1.5")
        force("androidx.test.espresso:espresso-core:3.5.1")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    androidTestImplementation("androidx.test:runner:1.5.2")
    androidTestImplementation("androidx.test:rules:1.5.0")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}

flutter {
    source = "../.."
}
