import SwiftUI
import AVKit

struct A2UIVideoView: View {
    let properties: VideoProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        if let urlString = surface.resolve(properties.url), let url = URL(string: urlString) {
            VideoPlayer(player: AVPlayer(url: url))
                .frame(minHeight: 200)
                .cornerRadius(8)
        }
    }
}
