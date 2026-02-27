import SwiftUI

struct A2UICheckBoxView: View {
    let id: String
    let properties: CheckBoxProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    init(id: String, properties: CheckBoxProperties, surface: SurfaceState? = nil) {
        self.id = id
        self.properties = properties
        self.surface = surface
    }

    var body: some View {
        let isOnBinding = Binding<Bool>(
            get: {
                resolveValue(activeSurface, binding: properties.value) ?? false
            },
            set: { newValue in
                updateBinding(surface: activeSurface, binding: properties.value, newValue: newValue)
                activeSurface?.runChecks(for: id)
            }
        )

        Toggle(isOn: isOnBinding) {
            Text(resolveValue(activeSurface, binding: properties.label) ?? "")
        }
        .onAppear {
            activeSurface?.runChecks(for: id)
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    A2UICheckBoxView(id: "cb1", properties: CheckBoxProperties(
        label: .init(literal: "Check this box"),
        value: .init(literal: true)
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
