# A2UI Swift Renderer

This directory contains the source code for the A2UI Swift Renderer.

It is a native Swift package that provides the necessary components to parse and render A2UI protocol messages within a SwiftUI application.

## Key Components:

-   **A2UIParser**: Deserializes A2UI JSON messages into Swift data models.
-   **A2UIDataStore**: Manages the state of the UI surface and its components.
-   **A2UISurfaceView**: A SwiftUI view that orchestrates the rendering of the entire A2UI surface.
-   **A2UIComponentRenderer**: A view responsible for dynamically rendering individual A2UI components (e.g., Text, Button, Card) as native SwiftUI views.

For an example of how to use this renderer, please see the sample application in `samples/client/swift`.

## Usage

To use this package in your Xcode project:

1.  Go to **File > Add Packages...**
2.  In the "Add Package" dialog, click **Add Local...**
3.  Navigate to this directory (`renderers/swift`) and click **Add Package**.
4.  Select the `A2UI` library to be added to your application target.

## Running Tests

You can run the included unit tests using either Xcode or the command line.

### Xcode

1.  Open the `Package.swift` file in this directory with Xcode.
2.  Go to the **Test Navigator** (Cmd+6).
3.  Click the play button to run all tests.

### Command Line

Navigate to this directory in your terminal and run:

```bash
swift test
```
