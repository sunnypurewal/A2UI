import SwiftUI

struct A2UISliderView: View {
    let id: String
    let properties: SliderProperties
    @Environment(SurfaceState.self) var surface
    @State private var value: Double = 0

    init(id: String, properties: SliderProperties) {
        self.id = id
        self.properties = properties
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = surface.resolve(label) {
                Text(labelText)
                    .font(.caption)
            }

            Slider(value: $value, in: properties.min...properties.max) {
                Text("Slider")
            } minimumValueLabel: {
                Text("\(Int(properties.min))")
            } maximumValueLabel: {
                Text("\(Int(properties.max))")
            }
            .onChange(of: value) { _, newValue in
                updateBinding(surface: surface, binding: properties.value, newValue: newValue)
                surface.runChecks(for: id)
            }
        }
        .onAppear {
            value = resolveValue(surface, binding: properties.value) ?? properties.min
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
