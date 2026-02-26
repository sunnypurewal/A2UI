import SwiftUI

@MainActor func updateBinding<T: Sendable>(surface: SurfaceState, binding: BoundValue<T>?, newValue: T) {
    guard let path = binding?.path else { return }
    surface.trigger(action: .dataUpdate(DataUpdateAction(path: path, contents: AnyCodable(newValue))))
}

@MainActor func resolveValue<T>(_ surface: SurfaceState, binding: BoundValue<T>?) -> T? {
    guard let binding = binding else { return nil }
    return surface.resolve(binding)
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
