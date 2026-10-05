// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.13.1")
    }
}

allprojects {
    repositories {
        mavenCentral()
        google()
    }
}
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory.asFile.get())
}
