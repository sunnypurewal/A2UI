import SwiftUI

struct A2UISliderView: View {
    let id: String
    let properties: SliderProperties
    @Environment(SurfaceState.self) var surface

    init(id: String, properties: SliderProperties) {
        self.id = id
        self.properties = properties
    }

    var body: some View {
        let valueBinding = Binding<Double>(
            get: {
                resolveValue(surface, binding: properties.value) ?? properties.min
            },
            set: { newValue in
                updateBinding(surface: surface, binding: properties.value, newValue: newValue)
                surface.runChecks(for: id)
            }
        )

        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = surface.resolve(label) {
                Text(labelText)
                    .font(.caption)
            }

            Slider(value: valueBinding, in: properties.min...properties.max) {
                Text("Slider")
            } minimumValueLabel: {
                Text("\(Int(properties.min))")
            } maximumValueLabel: {
                Text("\(Int(properties.max))")
            }
        }
        .onAppear {
            surface.runChecks(for: id)
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
