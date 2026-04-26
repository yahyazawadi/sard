// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sard"
    compileSdk = 36 //flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
defaultConfig {
        applicationId = "com.example.sard"
        minSdk = 24  // ← Change to 24 (Android 7.0+ for permission_handler)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // defaultConfig {
    //     // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    //     applicationId = "com.example.sard"
    //     // You can update the following values to match your application needs.
    //     // For more information, see: https://flutter.dev/to/review-gradle-config.
    //     minSdk = flutter.minSdkVersion
    //     targetSdk = flutter.targetSdkVersion
    //     versionCode = flutter.versionCode
    //     versionName = flutter.versionName
    // }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))
    implementation("androidx.activity:activity:1.9.3")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.core:core:1.13.1")
    implementation("androidx.core:core-splashscreen") {
        version { strictly("1.0.1") }
    }
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
}