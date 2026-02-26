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

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    HStack(spacing: 20) {
        A2UIIconView(properties: IconProperties(name: .init(literal: "star")))
        A2UIIconView(properties: IconProperties(name: .init(literal: "heart")))
        A2UIIconView(properties: IconProperties(name: .init(literal: "person")))
    }
    .padding()
    .environment(surface)
    .environment(dataStore)
}
