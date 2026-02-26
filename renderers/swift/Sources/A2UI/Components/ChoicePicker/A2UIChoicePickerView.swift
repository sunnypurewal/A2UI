import SwiftUI

struct A2UIChoicePickerView: View {
    let id: String
    let properties: ChoicePickerProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    @State private var selections: Set<String> = []
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    init(id: String, properties: ChoicePickerProperties, surface: SurfaceState? = nil) {
        self.id = id
        self.properties = properties
        self.surface = surface
    }

    var body: some View {
		let variant = properties.variant ?? .mutuallyExclusive
        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = activeSurface?.resolve(label) {
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
                        Text(activeSurface?.resolve(option.label) ?? option.value).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Menu {
                    ForEach(properties.options, id: \.value) { option in
                        Toggle(activeSurface?.resolve(option.label) ?? option.value, isOn: Binding(
                            get: { selections.contains(option.value) },
                            set: { isOn in
                                if isOn {
                                    selections.insert(option.value)
                                } else {
                                    selections.remove(option.value)
                                }
                            }
                        ))
                    }
                } label: {
                    HStack {
                        let selectedLabels = properties.options
                            .filter { selections.contains($0.value) }
                            .compactMap { activeSurface?.resolve($0.label) }
                        
                        let labelText = if selectedLabels.isEmpty {
                            "Select..."
                        } else if selectedLabels.count > 2 {
                            "\(selectedLabels.count) items"
                        } else {
                            selectedLabels.joined(separator: ", ")
                        }
                        
                        Text(labelText)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
#if os(iOS)
                .menuActionDismissBehavior(.disabled)
#endif
            }
        }
        .onChange(of: selections) { _, newValue in
            updateBinding(surface: activeSurface, binding: properties.value, newValue: Array(newValue))
            activeSurface?.runChecks(for: id)
        }
        .onAppear {
            if let initial = activeSurface?.resolve(properties.value) {
                selections = Set(initial)
            }
            activeSurface?.runChecks(for: id)
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    let options = [
        SelectionOption(label: .init(literal: "Option 1"), value: "opt1"),
        SelectionOption(label: .init(literal: "Option 2"), value: "opt2"),
        SelectionOption(label: .init(literal: "Option 3"), value: "opt3")
    ]
    
    VStack(spacing: 20) {
        A2UIChoicePickerView(id: "cp1", properties: ChoicePickerProperties(
            label: .init(literal: "Mutually Exclusive"),
            options: options,
            variant: .mutuallyExclusive,
            value: .init(literal: ["opt1"])
        ))
        
        A2UIChoicePickerView(id: "cp2", properties: ChoicePickerProperties(
            label: .init(literal: "Multiple Selection"),
            options: options,
            variant: .multipleSelection,
            value: .init(literal: ["opt1", "opt2"])
        ))
    }
    .padding()
    .environment(surface)
    .environment(dataStore)
}
