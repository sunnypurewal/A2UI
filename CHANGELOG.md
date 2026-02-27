# Changelog

This document summarizes the initial implementation of the A2UI protocol in Swift, covering the development of the SwiftUI renderer and the sample client application.

## [0.9.0] - Initial Swift Implementation

### SwiftUI Renderer
- **Protocol Support**: Implemented a native SwiftUI renderer for the A2UI v0.9 specification.
- **Basic Catalog Components**: Full support for standard UI components:
  - **Layout**: `Row`, `Column`, `List`, `Card`, `Tabs`, `Divider`.
  - **Content**: `Text`, `Heading`, `Image`, `Icon`, `Video`, `AudioPlayer`.
  - **Input**: `TextField`, `Button`, `CheckBox`, `Slider`, `DateTimeInput`, `MultipleChoice`.
  - **Overlays**: `Modal`.
- **Standard Functions**: Implemented a function evaluation engine for catalog functions:
  - **Validation**: `required`, `email`, `numeric`, `regex`.
  - **Formatting**: `formatDate`, `formatCurrency`, `pluralize`.
- **Data Binding**: Integrated `A2UIDataStore` for managing reactive, JSON-based data models and template resolution.
- **Media Integration**: Native `AVPlayer` integration for audio and video components with custom playback controls.
- **SF Symbols Mapping**: Automatic mapping of Material/Google Font icon names to native iOS/macOS SF Symbols.

### Sample Client Application
- **Interactive Gallery**: A comprehensive demonstration app showcasing every component in the basic catalog.
- **JSON Exploration**: Tools to visualize the bidirectional relationship between A2UI JSON definitions and rendered SwiftUI views.
- **Live Data Model Editing**: Real-time editors to modify the underlying data model and observe reactive UI updates.
- **Function Demos**: Interactive examples for testing A2UI standard functions and input validation rules.
- **Action Logging**: Integrated log view to monitor `UserAction` events emitted by the renderer.

### Architecture & Quality
- **Modular Design**: Structured the library into specialized modules for Components, Models, Functions, and Data Management.
- **Comprehensive Testing**: Established a robust test suite using the Swift Testing framework, achieving high coverage across core rendering and logic files.
- **Cross-Platform**: Designed for compatibility across iOS and macOS platforms.
- **Documentation**: Updated READMEs and provided implementation guides for Swift-based agent and client development.
