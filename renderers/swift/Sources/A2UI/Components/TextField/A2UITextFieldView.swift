import SwiftUI

struct A2UITextFieldView: View {
    let id: String
    let properties: TextFieldProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    init(id: String, properties: TextFieldProperties, surface: SurfaceState? = nil) {
        self.id = id
        self.properties = properties
        self.surface = surface
    }

    var body: some View {
		let label = resolveValue(activeSurface, binding: properties.label) ?? ""
		let variant = properties.variant ?? .shortText
        
        let textBinding = Binding(
            get: { resolveValue(activeSurface, binding: properties.value) ?? "" },
            set: { newValue in
                updateBinding(surface: activeSurface, binding: properties.value, newValue: newValue)
                activeSurface?.runChecks(for: id)
            }
        )

        VStack(alignment: .leading, spacing: 4) {
			if variant == .obscured {
				SecureField(label, text: textBinding)
			} else if variant == .longText {
				Text(label)
					.font(.caption)
					.foregroundColor(.secondary)
				TextEditor(text: textBinding)
			} else {
				                            TextField(label, text: textBinding)
				#if os(iOS)
				                                    .keyboardType(variant == .number ? .decimalPad : .default)
				#endif

			}
			if let error = activeSurface?.validationErrors[id] {
				Text(error)
					.font(.caption)
					.foregroundColor(.red)
			}
        }
		.textFieldStyle(.roundedBorder)
        .onAppear {
			activeSurface?.runChecks(for: id)
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    return VStack(spacing: 20) {
        A2UITextFieldView(id: "tf1", properties: TextFieldProperties(
            label: .init(literal: "Short Text"),
            value: .init(literal: ""),
            variant: .shortText
        ))
        
        A2UITextFieldView(id: "tf2", properties: TextFieldProperties(
            label: .init(literal: "Number Input"),
            value: .init(literal: ""),
            variant: .number
        ))
        
        A2UITextFieldView(id: "tf3", properties: TextFieldProperties(
            label: .init(literal: "Obscured Input"),
            value: .init(literal: ""),
            variant: .obscured
        ))
    }
    .padding()
    .environment(surface)
    .environment(dataStore)
}
