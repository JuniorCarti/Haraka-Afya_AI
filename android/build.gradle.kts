// Configure repositories for all subprojects
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Customize the root project's build output directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Apply the new build directory path to all subprojects
subprojects {
    val subprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(subprojectBuildDir)

    // Optional: Prevent double application of plugins (for safety)
    plugins.withId("com.google.gms.google-services") {
        // The plugin is already applied in the app module; no need to apply here.
    }
}

// Define a clean task to delete the entire build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
