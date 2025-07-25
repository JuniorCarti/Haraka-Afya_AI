plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Flutter plugin must be applied after Android & Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.haraka_afya_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Correct Kotlin DSL syntax 
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.haraka_afya_ai"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Temporary: using debug signing config so release builds can run
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // ✅ This is critical
    // Firebase BoM ensures all Firebase libraries use compatible versions
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // Firebase core services
    implementation("com.google.firebase:firebase-analytics")

    // OPTIONAL: Uncomment below as needed
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-messaging")
}
