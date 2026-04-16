plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mirror"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ✅ এখানে পরিবর্তন করা হয়েছে: 'jvmTarget' এর নতুন নিয়ম
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.mirror"

        // ✅ ক্যামেরা প্যাকেজের জন্য এটি সরাসরি ২১ করে দেওয়া হলো
        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        // ✅ এখানে flutter.code এর বদলে flutter.versionCode হবে
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
