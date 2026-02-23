# A2UI Swift Explorer

This directory contains the source code for the A2UI Explorer, a sample application demonstrating the capabilities of the Swift renderer.

## Why no `.xcodeproj`?
To keep the open-source repository clean and avoid "Bundle Identifier" issues common with shared Xcode projects, we provide the raw source files.

## How to Run (iOS Simulator / Mac)
1. In Xcode, go to **File > New > Project**.
2. Select **iOS > App** or **macOS > App**.
3. Name it **A2UIExplorer** (use your own Team/Organization identifier).
4. **Add Dependency**: Right-click your project, select **Add Package Dependencies...**, click **Add Local...**, and select the `renderers/swift` folder.
5. **Add Files**: Drag all `.swift` files from the `Samples/A2UIExplorer/A2UIExplorer/` folder into your new project.
6. **Clean Up**: Delete the default `ContentView.swift` and the `@main` struct in your generated `App.swift` (since `A2UIExplorerApp.swift` provides its own).
7. **Run**: Select your simulator and press **Cmd + R**.
