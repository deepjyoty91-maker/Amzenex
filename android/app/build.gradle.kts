import java.io.File

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.medmylife.app.medmylife"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.medmylife.app.medmylife"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Strip C++ debug symbols from native shared libraries using llvm-objcopy
tasks.register("stripEngineSymbols") {
    doLast {
        val objcopyExecutable = File(
            "/Users/deepjyoty/Library/Android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-objcopy"
        )

        if (objcopyExecutable.exists()) {
            val buildDir = layout.buildDirectory.get().asFile
            buildDir.walkTopDown().filter { it.extension == "so" }.forEach { soFile ->
                try {
                    val pb = ProcessBuilder(objcopyExecutable.absolutePath, "--strip-unneeded", soFile.absolutePath)
                    val process = pb.start()
                    process.waitFor()
                } catch (e: Exception) {
                    println("Failed to strip $soFile: $e")
                }
            }
        }
    }
}

tasks.whenTaskAdded {
    if (name.startsWith("package") && name.contains("Release")) {
        dependsOn("stripEngineSymbols")
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
