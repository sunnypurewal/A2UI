import SwiftUI

struct A2UITextFieldView: View {
    let properties: TextFieldProperties
    @Environment(SurfaceState.self) var surface
    @State private var text: String = ""

    var body: some View {
		let label = resolveValue(surface, binding: properties.label) ?? ""
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
					.keyboardType(variant == .number ? .decimalPad : .default)
			}
        }
		.textFieldStyle(.roundedBorder)
		.onChange(of: text) { _, newValue in
			updateBinding(surface: surface, binding: properties.value, newValue: newValue)
		}
        .onAppear {
            text = resolveValue(surface, binding: properties.value) ?? ""
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    VStack(spacing: 20) {
        A2UITextFieldView(properties: TextFieldProperties(
            label: .init(literal: "Short Text"),
            value: .init(literal: ""),
            variant: .shortText
        ))
        
        A2UITextFieldView(properties: TextFieldProperties(
            label: .init(literal: "Number Input"),
            value: .init(literal: ""),
            variant: .number
        ))
        
        A2UITextFieldView(properties: TextFieldProperties(
            label: .init(literal: "Obscured Input"),
            value: .init(literal: ""),
            variant: .obscured
        ))
    }
    .padding()
    .environment(surface)
    .environment(dataStore)
}
