import SwiftUI

struct A2UIColumnView: View {
    let properties: ContainerProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        let childIds: [String] = {
            switch properties.children {
            case .list(let list): return list
            case .template(let template): return surface.expandTemplate(template: template)
            }
        }()

        VStack(alignment: horizontalAlignment, spacing: 0) {
            A2UIJustifiedContainer(childIds: childIds, justify: properties.resolvedJustify)
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
