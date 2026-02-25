import SwiftUI

struct A2UIJustifiedContainer: View {
    let childIds: [String]
    let justify: A2UIJustify

    var body: some View {
        if justify == .end || justify == .center || justify == .spaceEvenly || justify == .spaceAround {
            Spacer(minLength: 0)
        }

        ForEach(Array(childIds.enumerated()), id: \.offset) { index, id in
            A2UIComponentRenderer(componentId: id)
            if index < childIds.count - 1 {
                if justify == .spaceBetween || justify == .spaceEvenly || justify == .spaceAround {
                    Spacer(minLength: 0)
                }
            }
        }

        if justify == .start || justify == .center || justify == .spaceEvenly || justify == .spaceAround {
            Spacer(minLength: 0)
        }
    }
}

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
