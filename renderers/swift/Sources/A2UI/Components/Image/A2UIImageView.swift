import SwiftUI

struct A2UIImageView: View {
    let properties: ImageProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        if let urlString = surface.resolve(properties.url), let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
			.accessibilityLabel(properties.variant?.rawValue ?? "Image")
			.mask(RoundedRectangle(cornerRadius: properties.variant == .avatar ? .infinity : 0))
        }
    }

    private var contentMode: ContentMode {
        switch properties.fit {
			case .cover, .fill: return .fill
			default: return .fit
        }
    }
}
