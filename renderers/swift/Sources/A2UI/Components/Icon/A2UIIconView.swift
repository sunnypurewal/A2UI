import SwiftUI

struct A2UIIconView: View {
    let properties: IconProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        if let name = surface.resolve(properties.name) {
			Image(systemName: A2UIIconName(rawValue: name)!.sfSymbolName)
                .font(.system(size: 24))
                .foregroundColor(.primary)
        }
    }

    private func mapToSFSymbol(_ name: String) -> String {
        return name
    }
}
