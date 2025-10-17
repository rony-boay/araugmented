plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle plugin must come after Android + Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.araugmented"

    // ✅ Recommended compile SDK for AGP 8.9.1
    compileSdk = 35

    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.araugmented"

        // ✅ Set your min and target SDKs here
        minSdk = flutter.minSdkVersion
        targetSdk = 35

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            // TODO: Use your real signing config before publishing
            signingConfig = signingConfigs.getByName("debug")
            // ProGuard (if you want to enable later)
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        // ✅ Java 17 for AGP 8.9+ compatibility
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // Optional performance tweaks
    packaging {
        resources.excludes.add("META-INF/*")
    }

    // Speeds up builds by skipping unnecessary tasks
    buildFeatures {
        aidl = false
        renderScript = false
        shaders = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Kotlin & AndroidX core libs
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")

    // Optional: AR & camera libs (if your app uses them)
    implementation("com.google.ar:core:1.45.0")
    implementation("androidx.camera:camera-core:1.3.4")
    implementation("androidx.camera:camera-camera2:1.3.4")
    implementation("androidx.camera:camera-lifecycle:1.3.4")
    implementation("androidx.camera:camera-view:1.3.4")
}
