# Objective
Implement the "functions" section of the A2UI Basic Catalog (v0.10) in the Swift renderer. This involves updating models to support function calls in dynamic values and implementing the evaluation logic for the standard set of functions.

# Key Files & Context
- `renderers/swift/Sources/A2UI/Models/BoundValue.swift`: Update to support `functionCall` in addition to `literal` and `path`.
- `renderers/swift/Sources/A2UI/Models/FunctionCall.swift`: Update to conform to `Equatable` and ensure it can be used within `BoundValue`.
- `renderers/swift/Sources/A2UI/Surface/SurfaceState.swift`: Update `resolve` to evaluate functions using a new evaluator.
- `renderers/swift/Sources/A2UI/Surface/A2UIFunctionEvaluator.swift`: (New) Centralized logic for evaluating catalog functions like `formatDate`, `regex`, `pluralize`, etc.

# Implementation Steps
1. **Model Updates**:
    - Update `FunctionCall.swift` to conform to `Equatable`.
    - Update `BoundValue.swift` to include `public let functionCall: FunctionCall?` and update its `init(from decoder:)` and `encode(to encoder:)` to handle the `FunctionCall` case.
2. **Function Evaluator Implementation**:
    - Create `renderers/swift/Sources/A2UI/Surface/A2UIFunctionEvaluator.swift`.
    - Implement a `resolveDynamicValue` helper that can handle literals, paths, and nested function calls.
    - Implement the standard library of functions:
        - Validation: `required`, `regex`, `length`, `numeric`, `email`.
        - Formatting: `formatString`, `formatNumber`, `formatCurrency`, `formatDate`.
        - Logic: `and`, `or`, `not`.
        - Utilities: `pluralize`, `openUrl`.
3. **Integration**:
    - Update `SurfaceState.swift` to use `A2UIFunctionEvaluator` in its `resolve` methods.
    - Ensure recursive resolution of arguments within function calls.
4. **Testing**:
    - Create `renderers/swift/Tests/A2UITests/A2UIFunctionTests.swift` to test each function with various inputs (literals and data model paths).

# Verification & Testing
- Build the project to ensure no regressions: `swift build` in `renderers/swift`.
- Run the newly created tests: `swift test` in `renderers/swift`.
- Verify complex functions like `pluralize` and `formatDate` (using TR35 patterns).
