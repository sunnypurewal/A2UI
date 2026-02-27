import SwiftUI

@MainActor func updateBinding<T: Sendable>(surface: SurfaceState?, binding: BoundValue<T>?, newValue: T) {
    guard let surface = surface, let path = binding?.path else { return }
    surface.triggerDataUpdate(path: path, value: newValue)
}

@MainActor func resolveValue<T>(_ surface: SurfaceState?, binding: BoundValue<T>?) -> T? {
    guard let surface = surface, let binding = binding else { return nil }
    return surface.resolve(binding)
}

@MainActor func errorMessage(surface: SurfaceState?, checks: [CheckRule]?) -> String? {
    guard let surface = surface, let checks = checks, !checks.isEmpty else { return nil }
    
    A2UILogger.debug("Evaluating \(checks.count) validation checks")
    
    for check in checks {
        let isValid = surface.resolve(check.condition) ?? true
        let conditionDesc = String(describing: check.condition)
        
        if !isValid {
            A2UILogger.debug("Check FAILED: \(check.message) (Condition: \(conditionDesc))")
            return check.message
        } else {
            A2UILogger.debug("Check PASSED (Condition: \(conditionDesc))")
        }
    }
    return nil
}

struct ValidationErrorMessageView: View {
    let id: String
    let surface: SurfaceState?

    var body: some View {
        if let surface = surface, let error = surface.validationErrors[id] {
            Text(error)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 2)
                .transition(.opacity)
        }
    }
}
