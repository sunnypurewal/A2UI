import SwiftUI

struct A2UIRowView: View {
    let properties: ContainerProperties
    @Environment(SurfaceState.self) var surface
	
	private var justify: A2UIJustify {
		properties.justify ?? .spaceBetween
	}

    var body: some View {
        let childIds: [String] = {
            switch properties.children {
            case .list(let list): return list
            case .template(let template): return surface.expandTemplate(template: template)
            }
        }()

        HStack(alignment: verticalAlignment, spacing: 0) {
			A2UIJustifiedContainer(childIds: childIds, justify: justify)
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalAlignment: VerticalAlignment {
        switch properties.resolvedAlign {
        case .start: return .top
        case .center: return .center
        case .end: return .bottom
        default: return .center
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    surface.components["t1"] = ComponentInstance(id: "t1", component: .text(TextProperties(text: .init(literal: "Left"), variant: nil)))
    surface.components["t2"] = ComponentInstance(id: "t2", component: .text(TextProperties(text: .init(literal: "Right"), variant: nil)))
    
    return A2UIRowView(properties: ContainerProperties(
        children: .list(["t1", "t2"]),
        justify: .spaceBetween,
        align: .center
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
