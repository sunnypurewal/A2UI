import SwiftUI
import OSLog

private let log = OSLog(subsystem: "org.a2ui.renderer", category: "Validation")

@MainActor func updateBinding<T: Sendable>(surface: SurfaceState, binding: BoundValue<T>?, newValue: T) {
    guard let path = binding?.path else { return }
    surface.trigger(action: .dataUpdate(DataUpdateAction(path: path, contents: AnyCodable(newValue))))
}

@MainActor func resolveValue<T>(_ surface: SurfaceState, binding: BoundValue<T>?) -> T? {
    guard let binding = binding else { return nil }
    return surface.resolve(binding)
}

@MainActor func errorMessage(surface: SurfaceState, checks: [CheckRule]?) -> String? {
    guard let checks = checks, !checks.isEmpty else { return nil }
    
    os_log("Evaluating %d validation checks", log: log, type: .debug, checks.count)
    
    for check in checks {
        let isValid = surface.resolve(check.condition) ?? true
        let conditionDesc = String(describing: check.condition)
        
        if !isValid {
            os_log("Check FAILED: %{public}@ (Condition: %{public}@)", log: log, type: .debug, check.message, conditionDesc)
            return check.message
        } else {
            os_log("Check PASSED (Condition: %{public}@)", log: log, type: .debug, conditionDesc)
        }
    }
    return nil
}

struct CheckBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}
