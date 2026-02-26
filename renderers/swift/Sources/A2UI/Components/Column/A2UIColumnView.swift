import SwiftUI

struct A2UIColumnView: View {
    let properties: ContainerProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    var body: some View {
        let childIds: [String] = {
            switch properties.children {
            case .list(let list): return list
            case .template(let template): return activeSurface?.expandTemplate(template: template) ?? []
            }
        }()

        VStack(alignment: horizontalAlignment, spacing: 0) {
            A2UIJustifiedContainer(childIds: childIds, justify: properties.resolvedJustify)
                .environment(activeSurface)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment(horizontal: horizontalAlignment, vertical: .center))
    }

    private var horizontalAlignment: HorizontalAlignment {
		switch properties.resolvedAlign {
			case .start: return .leading
			case .center: return .center
			case .end: return .trailing
			default: return .leading
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    surface.components["t1"] = ComponentInstance(id: "t1", component: .text(TextProperties(text: .init(literal: "Top"), variant: nil)))
    surface.components["t2"] = ComponentInstance(id: "t2", component: .text(TextProperties(text: .init(literal: "Bottom"), variant: nil)))
    
    return A2UIColumnView(properties: ContainerProperties(
        children: .list(["t1", "t2"]),
        justify: .start,
        align: .center
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
