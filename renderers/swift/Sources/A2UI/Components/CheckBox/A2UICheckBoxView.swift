import SwiftUI

struct A2UICheckBoxView: View {
    let properties: CheckBoxProperties
    @Environment(SurfaceState.self) var surface
    @State private var isOn: Bool = false

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(resolveValue(surface, binding: properties.label) ?? "")
        }
        .toggleStyle(CheckBoxToggleStyle())
        .onChange(of: isOn) { _, newValue in
            updateBinding(surface: surface, binding: properties.value, newValue: newValue)
        }
        .onAppear {
            isOn = resolveValue(surface, binding: properties.value) ?? false
        }
    }
}
