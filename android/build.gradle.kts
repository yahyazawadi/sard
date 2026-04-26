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
    val project = this
    if (project.state.executed) {
        configureProject(project)
    } else {
        project.afterEvaluate {
            configureProject(project)
        }
    }
}

fun configureProject(project: Project) {
    if (project.hasProperty("android")) {
        val android = project.extensions.getByName("android") as? com.android.build.gradle.BaseExtension
        android?.compileSdkVersion(36)
    }
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
            if (requested.group == "androidx.core" && requested.name != "core-splashscreen") {
                useVersion("1.13.1")
            }
            if (requested.group == "androidx.core" && requested.name == "core-splashscreen") {
                useVersion("1.0.1")
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

subprojects {
    project.plugins.configureEach {
        if (this is com.android.build.gradle.api.AndroidBasePlugin) {
            val android = project.extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val parser = javax.xml.parsers.DocumentBuilderFactory.newInstance().newDocumentBuilder()
                    val document = parser.parse(manifestFile)
                    val packageName = document.documentElement.getAttribute("package")
                    if (packageName.isNotEmpty()) {
                        android.namespace = packageName
                    }
                }
            }
        }
    }
}