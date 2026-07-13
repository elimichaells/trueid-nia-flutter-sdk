plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.trueid.nia.flutter"
version = "1.0.2"

android {
    namespace = "com.trueid.nia.flutter"
    compileSdk = 35

    defaultConfig {
        minSdk = 24
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://app.trueid.info/sdk/android") }
}

dependencies {
    val localNia = findProject(":trueid-nia-sdk")
    if (localNia != null) {
        add("api", localNia)
    } else {
        add("api", "com.trueid.sdk:trueid-nia-sdk:1.1.0")
    }
}
