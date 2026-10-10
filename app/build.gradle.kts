plugins {
    id("com.android.application")
}

val bcgVerifiedNative = System.getenv("BCG_VERIFIED_NATIVE") == "1"
val bcgEngineLibs = tasks.register<Sync>("prepareBcgEngineLibs") {
    from("src/main/jniLibs")
    exclude("**/libsamp.so", "**/libc++_shared.so", "**/libshadowhook.so")
    into(layout.buildDirectory.dir("bcgEngineLibs"))
}
if (!bcgVerifiedNative) tasks.named("preBuild") { dependsOn(bcgEngineLibs) }

android {
    val bcgKeystorePath = System.getenv("BCG_SIGNING_KEYSTORE")
    signingConfigs {
        if (!bcgKeystorePath.isNullOrBlank()) {
            create("bcgDevelopment") {
                storeFile = file(bcgKeystorePath)
                storePassword = System.getenv("BCG_SIGNING_STORE_PASSWORD") ?: "android"
                keyAlias = System.getenv("BCG_SIGNING_ALIAS") ?: "androiddebugkey"
                keyPassword = System.getenv("BCG_SIGNING_KEY_PASSWORD") ?: "android"
            }
        }
    }
    compileSdk = 36
    buildToolsVersion = "36.0.0"

    // Mantém os nomes Java/JNI existentes; o pacote instalado é o applicationId abaixo.
    namespace = "com.gta.game"

    defaultConfig {
        applicationId = "com.cidadegranderp"
        minSdk = 28
        targetSdk = 36
        versionCode = 53
        versionName = "0.0.53-r2"

        ndk {
            abiFilters.add("arm64-v8a")
        }

        if (!bcgVerifiedNative) externalNativeBuild {
            cmake {
                arguments.add("-DANDROID_STL=c++_shared")
            }
        }

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    packaging {
        jniLibs {
            // O prefab do ShadowHook e o CMake apontam para o mesmo binário.
            // Mantém uma única cópia no APK e extrai as libs para o carregador do GTA SA.
            pickFirsts.add("lib/arm64-v8a/libshadowhook.so")
            useLegacyPackaging = true
            if (bcgVerifiedNative) keepDebugSymbols.add("**/*.so")
            excludes.add("META-INF/*")
        }
        resources {
            excludes.add("META-INF/*")
        }
    }

    if (bcgVerifiedNative) {
        sourceSets.getByName("main").jniLibs.srcDir("src/main/cpp/samp/vendor/bass/libs")
    } else {
        sourceSets.getByName("main").jniLibs.setSrcDirs(listOf(layout.buildDirectory.dir("bcgEngineLibs")))
    }

    ndkVersion = "28.2.13676358"

    if (!bcgVerifiedNative) externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }

    applicationVariants.all {
        outputs.all {
            val apkName = "CG-SAMP-V053-R2-CHARACTER-FIX-${buildType.name}.apk"
            (this as com.android.build.gradle.internal.api.BaseVariantOutputImpl).outputFileName = apkName
        }
    }

    buildTypes {
        debug {
            if (!bcgKeystorePath.isNullOrBlank()) signingConfig = signingConfigs.getByName("bcgDevelopment")
            isDebuggable = true
            isJniDebuggable = true
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            ndk {
                debugSymbolLevel = "FULL"
            }
        }
        release {
            if (!bcgKeystorePath.isNullOrBlank()) signingConfig = signingConfigs.getByName("bcgDevelopment")

            ndk {
                debugSymbolLevel = "FULL"
            }

            isDebuggable = false
            isJniDebuggable = false
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        checkReleaseBuilds = true
        abortOnError = true
    }

    buildFeatures {
        prefab = true
    }
}

dependencies {
    implementation("androidx.credentials:credentials:1.5.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.5.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.2.0")
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:1.8.22"))
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.core:core-ktx:1.12.0")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    implementation("com.intuit.sdp:sdp-android:1.1.0")
    implementation("com.bytedance.android:shadowhook:1.0.10")
}
