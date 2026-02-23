import SwiftUI

struct A2UIButtonView: View {
    @Environment(SurfaceState.self) var surface
    let properties: ButtonProperties

    var body: some View {
        Button(action: {
            performAction()
        }) {
            A2UIComponentRenderer(componentId: properties.child)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .applyButtonStyle(variant: properties.variant)
        #if os(iOS)
        .tint(properties.variant == "primary" ? .blue : .gray)
        #endif
    }

    private func performAction() {
        surface.trigger(action: properties.action)
    }
}

extension View {
    @ViewBuilder
    func applyButtonStyle(variant: String?) -> some View {
        if variant == "borderless" {
            self.buttonStyle(.plain)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}
