buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 🔧 Kotlin version used for all Kotlin-based Gradle plugins
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // 🔧 Firebase plugin
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional build dir customization (keep if you need it)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
