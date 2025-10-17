pluginManagement {
    // Read Flutter SDK path from local.properties
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val path = properties.getProperty("flutter.sdk")
        require(path != null) { "flutter.sdk not set in local.properties" }
        path
    }

    // Include Flutter's Gradle tools
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // Optional: add Flutter local Maven repo for faster sync
        maven {
            url = uri("$flutterSdkPath/bin/cache/artifacts/engine/android")
        }
    }
}

plugins {
    // ✅ FIXED: Perfect 2025 Versions
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0"
    id("com.android.application") version "8.5.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // Optional JitPack repo for 3rd-party SDKs
        maven("https://jitpack.io")
    }
}

// Include main app module
include(":app")

// Optional: enforce plugin sync stability
gradle.startParameter.showStacktrace = org.gradle.api.logging.configuration.ShowStacktrace.ALWAYS_FULL