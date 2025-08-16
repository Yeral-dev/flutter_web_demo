// File: android/build.gradle.kts

// Configuración de plugins
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}

// Configuración de repositorios
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuración de directorios de compilación
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Tarea de limpieza
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Dependencias necesarias para Firebase y herramientas de Gradle
buildscript {
    dependencies {
        // Firebase y Google Services
        classpath("com.google.gms:google-services:4.3.15") // 
        classpath("com.android.tools.build:gradle:8.7.0") // 
    }
}
