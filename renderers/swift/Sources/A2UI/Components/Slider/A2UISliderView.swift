import SwiftUI

struct A2UISliderView: View {
    let id: String
    let properties: SliderProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    init(id: String, properties: SliderProperties, surface: SurfaceState? = nil) {
        self.id = id
        self.properties = properties
        self.surface = surface
    }

    var body: some View {
        let valueBinding = Binding<Double>(
            get: {
                resolveValue(activeSurface, binding: properties.value) ?? properties.min
            },
            set: { newValue in
                updateBinding(surface: activeSurface, binding: properties.value, newValue: newValue)
                activeSurface?.runChecks(for: id)
            }
        )

        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = activeSurface?.resolve(label) {
                Text(labelText)
                    .font(.caption)
            }

            Slider(value: valueBinding, in: properties.min...properties.max, step: 1) {
                Text("Slider")
            } minimumValueLabel: {
                Text("\(Int(properties.min))")
            } maximumValueLabel: {
                Text("\(Int(properties.max))")
            }
            ValidationErrorMessageView(id: id, surface: activeSurface)
        }
        .onAppear {
            activeSurface?.runChecks(for: id)
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    A2UISliderView(id: "sl1", properties: SliderProperties(
        label: .init(literal: "Adjust Value"),
        min: 0,
        max: 100,
        value: .init(literal: 50.0)
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
