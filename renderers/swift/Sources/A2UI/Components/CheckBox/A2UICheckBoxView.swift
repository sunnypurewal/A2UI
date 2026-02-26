import SwiftUI

struct A2UICheckBoxView: View {
    let id: String
    let properties: CheckBoxProperties
    @Environment(SurfaceState.self) var surface
    @State private var isOn: Bool = false

    init(id: String, properties: CheckBoxProperties) {
        self.id = id
        self.properties = properties
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(resolveValue(surface, binding: properties.label) ?? "")
        }
        .onChange(of: isOn) { _, newValue in
            updateBinding(surface: surface, binding: properties.value, newValue: newValue)
            surface.runChecks(for: id)
        }
        .onAppear {
            isOn = resolveValue(surface, binding: properties.value) ?? false
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
