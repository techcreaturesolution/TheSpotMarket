import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase config is supplied by the developer (see README); the build still works without it.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.thespotmarket.thespotmarket"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.thespotmarket.thespotmarket"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        multiDexEnabled = true
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (!keystorePropertiesFile.exists()) {
                throw GradleException("Release signing failed: 'key.properties' file not found at ${keystorePropertiesFile.absolutePath}")
            }

            val storePasswordProp = keystoreProperties.getProperty("storePassword")
            val keyPasswordProp = keystoreProperties.getProperty("keyPassword")
            val keyAliasProp = keystoreProperties.getProperty("keyAlias")
            val storeFilePathProp = keystoreProperties.getProperty("storeFile")

            val missingProps = mutableListOf<String>()
            if (storePasswordProp.isNullOrBlank()) missingProps.add("storePassword")
            if (keyPasswordProp.isNullOrBlank()) missingProps.add("keyPassword")
            if (keyAliasProp.isNullOrBlank()) missingProps.add("keyAlias")
            if (storeFilePathProp.isNullOrBlank()) missingProps.add("storeFile")

            if (missingProps.isNotEmpty()) {
                throw GradleException("Release signing failed: Missing or empty properties in 'key.properties': ${missingProps.joinToString(", ")}")
            }

            val keystoreFile = file(storeFilePathProp)
            if (!keystoreFile.exists()) {
                throw GradleException("Release signing failed: Keystore file does not exist at path: $storeFilePathProp")
            }

            keyAlias = keyAliasProp
            keyPassword = keyPasswordProp
            storeFile = keystoreFile
            storePassword = storePasswordProp
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
