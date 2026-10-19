plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vanya630.lectureswtimecodes"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vanya630.lectureswtimecodes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// whisper_kit treats language "auto" as detect-only and returns no words.
// Clear that flag so the model still picks the language and then transcribes.
val whisperLanguageFix = tasks.register("fixWhisperLanguage") {
    doLast {
        val source = file("${System.getProperty("user.home")}/.pub-cache/hosted/pub.dev/whisper_kit-0.3.1/src/main.cpp")
        if (!source.exists()) return@doLast
        val original = "wparams.detect_language = params.language == \"auto\";"
        val text = source.readText()
        if (original in text) {
            source.writeText(text.replace(original, "wparams.detect_language = false;"))
        }
    }
}
tasks.named("preBuild").configure { dependsOn(whisperLanguageFix) }
