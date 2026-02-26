import SwiftUI

struct A2UICheckBoxView: View {
    let id: String
    let properties: CheckBoxProperties
    @Environment(SurfaceState.self) var surface

    init(id: String, properties: CheckBoxProperties) {
        self.id = id
        self.properties = properties
    }

    var body: some View {
        let isOnBinding = Binding<Bool>(
            get: {
                resolveValue(surface, binding: properties.value) ?? false
            },
            set: { newValue in
                updateBinding(surface: surface, binding: properties.value, newValue: newValue)
                surface.runChecks(for: id)
            }
        )

        Toggle(isOn: isOnBinding) {
            Text(resolveValue(surface, binding: properties.label) ?? "")
        }
        .onAppear {
            surface.runChecks(for: id)
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
