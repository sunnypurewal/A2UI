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
