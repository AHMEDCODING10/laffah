allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://download.flutter.io") }
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }
        maven { url = uri("https://plugins.gradle.org/m2/") }
    }
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.google.maps.android" && requested.name == "android-maps-utils") {
                useVersion("4.0.0")
            }
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.1.20")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
