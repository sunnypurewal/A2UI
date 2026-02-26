import SwiftUI

struct A2UITextFieldView: View {
    let id: String
    let properties: TextFieldProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    @State var text: String = ""
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    init(id: String, properties: TextFieldProperties, surface: SurfaceState? = nil) {
        self.id = id
        self.properties = properties
        self.surface = surface
    }

    var body: some View {
		let label = resolveValue(activeSurface, binding: properties.label) ?? ""
		let variant = properties.variant ?? .shortText
        VStack(alignment: .leading, spacing: 4) {
			if variant == .obscured {
				SecureField(label, text: $text)
			} else if variant == .longText {
				Text(label)
					.font(.caption)
					.foregroundColor(.secondary)
				TextEditor(text: $text)
			} else {
				                            TextField(label, text: $text)
				#if os(iOS)
				                                    .keyboardType(variant == .number ? .decimalPad : .default)
				#endif
				
			}
        }
		.textFieldStyle(.roundedBorder)
		.onChange(of: text) { _, newValue in
			updateBinding(surface: activeSurface, binding: properties.value, newValue: newValue)
			activeSurface?.runChecks(for: id)
		}
        .onAppear {
            text = resolveValue(activeSurface, binding: properties.value) ?? ""
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
