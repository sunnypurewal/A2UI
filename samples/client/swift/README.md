# A2UI Swift Sample Client

This directory contains a sample iOS application that demonstrates how to use the A2UI Swift renderer.

The project is located in `A2UISampleApp/` and can be opened with Xcode.

## Purpose

This sample app serves as a practical example and testbed for the Swift renderer located in `renderers/swift`. It includes:

-   A **Component Gallery** showcasing different A2UI responses across various categories:
    - **Content**: `Text`, `Image`, `Icon`, `Video`, `AudioPlayer`
    - **Layout**: `Row`, `Column`, `List`
    - **Input**: `TextField`, `CheckBox`, `ChoicePicker`, `Slider`, `DateTimeInput`
    - **Navigation**: `Button`, `Modal`, `Tabs`
    - **Decoration**: `Divider`
    - **Functions**: Formatting (`Pluralize`, `FormatCurrency`, `FormatDate`) and Validation (`Required`, `Email`, `Regex`, `Length`, `Numeric`)
-   An integration of the `A2UISurfaceView` to dynamically render the A2UI responses.
-   Data Model demonstrations (e.g., updating bound variables and evaluating constraints).
-   A button to view the raw A2UI JSON definitions for each gallery example to easily understand the protocol representation.
