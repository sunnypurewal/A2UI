import SwiftUI

struct A2UITextFieldView: View {
    let properties: TextFieldProperties
    @Environment(SurfaceState.self) var surface
    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(resolveValue(surface, binding: properties.label) ?? "")
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { _, newValue in
                    updateBinding(surface: surface, binding: properties.value, newValue: newValue)
                }
        }
        .onAppear {
            text = resolveValue(surface, binding: properties.value) ?? ""
        }
    }
}
