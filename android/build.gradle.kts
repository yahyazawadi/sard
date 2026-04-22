//android/build.gradle.kts
buildscript {
    val kotlin_version = "1.9.20"  
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        classpath("com.google.gms:google-services:4.4.4")
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
// Force every subproject (plugin) to use compatible versions
subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.activity") {
                useVersion("1.9.3")
            }
            if (requested.group == "androidx.core") {
                useVersion("1.13.1")
            }
            if (requested.group == "androidx.lifecycle") {
                useVersion("2.8.7")
            }
            // This fixes that specific navigationevent error
            if (requested.group == "androidx.navigationevent") {
                useVersion("1.0.0-alpha03") 
            }
        }
    }
}