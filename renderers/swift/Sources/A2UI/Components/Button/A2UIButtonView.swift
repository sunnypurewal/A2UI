import SwiftUI

struct A2UIButtonView: View {
    @Environment(SurfaceState.self) var surface
    let properties: ButtonProperties

    var body: some View {
		let variant = properties.variant ?? .primary
        Button(action: {
            performAction()
        }) {
            A2UIComponentRenderer(componentId: properties.child)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .applyButtonStyle(variant: variant)
        #if os(iOS)
		.tint(variant == .primary ? .blue : .gray)
        #endif
    }

    private func performAction() {
        surface.trigger(action: properties.action)
    }
}

extension View {
    @ViewBuilder
    func applyButtonStyle(variant: ButtonVariant) -> some View {
		if variant == .borderless {
            self.buttonStyle(.borderless)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    // Add a text component for the button child
    surface.components["t1"] = ComponentInstance(id: "t1", component: .text(TextProperties(text: .init(literal: "Click Me"), variant: nil)))
    
	return VStack(spacing: 20) {
        A2UIButtonView(properties: ButtonProperties(
            child: "t1",
            action: .custom(name: "primary_action", context: nil),
			variant: .primary
        ))
        
        A2UIButtonView(properties: ButtonProperties(
            child: "t1",
            action: .custom(name: "borderless_action", context: nil),
			variant: .borderless
        ))
    }
    .padding()
    .environment(surface)
    .environment(dataStore)
}
