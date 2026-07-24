allprojects {
    repositories {
        google()
        mavenCentral()
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

// isar_flutter_libs 3.1.0+1 predates AGP's mandatory namespace requirement and doesn't
// declare one in its build.gradle, which breaks the build on AGP 8+. Inject it here.
subprojects {
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            val androidExt = extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
            if (androidExt != null) {
                if (androidExt.namespace == null) {
                    androidExt.namespace = "dev.isar.isar_flutter_libs"
                }
                // Its hardcoded compileSdkVersion 30 is too old for several transitive
                // androidx dependencies pulled in elsewhere in the app.
                androidExt.compileSdkVersion(36)
            }
        }
    }
}

// file_picker 11.0.2 skips applying the Kotlin Android plugin on AGP 9+, assuming AGP's
// built-in Kotlin support will compile its Kotlin sources instead — it doesn't, so
// FilePickerPlugin never gets compiled and the app build fails with "cannot find symbol".
// Apply the plugin ourselves before file_picker's own build.gradle evaluates.
subprojects {
    if (project.name == "file_picker") {
        pluginManager.apply("org.jetbrains.kotlin.android")
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
