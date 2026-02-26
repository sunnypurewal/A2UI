import SwiftUI

struct A2UIChoicePickerView: View {
    let properties: ChoicePickerProperties
    @Environment(SurfaceState.self) var surface
    @State private var selections: Set<String> = []

    var body: some View {
		let variant = properties.variant ?? .mutuallyExclusive
        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = surface.resolve(label) {
                Text(labelText)
                    .font(.caption)
            }

			if variant == .mutuallyExclusive {
                Picker("", selection: Binding(
                    get: { selections.first ?? "" },
                    set: { newValue in
                        selections = newValue.isEmpty ? [] : [newValue]
                    }
                )) {
                    ForEach(properties.options, id: \.value) { option in
                        Text(surface.resolve(option.label) ?? option.value).tag(option.value)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } else {
                ForEach(properties.options, id: \.value) { option in
                    Toggle(isOn: Binding(
                        get: { selections.contains(option.value) },
                        set: { isOn in
                            if isOn {
                                selections.insert(option.value)
                            } else {
                                selections.remove(option.value)
                            }
                        }
                    )) {
                        Text(surface.resolve(option.label) ?? option.value)
                    }
                }
            }
        }
        .onChange(of: selections) { _, newValue in
            updateBinding(surface: surface, binding: properties.value, newValue: Array(newValue))
        }
        .onAppear {
            if let initial = surface.resolve(properties.value) {
                selections = Set(initial)
            }
        }
    }
}
