import SwiftUI

struct A2UITextView: View {
    @Environment(SurfaceState.self) var surface
    let properties: TextProperties
	
	private var variant: A2UITextVariant { properties.variant ?? .body }

    var body: some View {
        let content = surface.resolve(properties.text) ?? ""
        
        Text(content)
            .font(fontFor(variant: variant))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func fontFor(variant: A2UITextVariant) -> Font {
        switch variant {
			case .h1: return .system(size: 34, weight: .bold)
			case .h2: return .system(size: 28, weight: .bold)
			case .h3: return .system(size: 22, weight: .bold)
			case .h4: return .system(size: 20, weight: .semibold)
			case .h5: return .system(size: 18, weight: .semibold)
			case .caption: return .caption
			default: return .body
        }
    }
}
