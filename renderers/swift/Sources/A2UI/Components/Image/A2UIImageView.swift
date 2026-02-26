import SwiftUI

struct A2UIImageView: View {
    let properties: ImageProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

        var body: some View {
                    let variant = properties.variant ?? .icon
            if let urlString = activeSurface?.resolve(properties.url), let url = URL(string: urlString) {
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
			.mask({
				if variant == .avatar {
					Circle()
				} else {
					Rectangle()
				}
			})
        }
    }

    private var contentMode: ContentMode {
        switch properties.fit {
			case .cover, .fill: return .fill
			default: return .fit
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    A2UIImageView(properties: ImageProperties(
        url: .init(literal: "https://picsum.photos/200/300"),
        fit: .cover,
        variant: .avatar
    ))
    .frame(width: 100, height: 100)
    .padding()
    .environment(surface)
    .environment(dataStore)
}
