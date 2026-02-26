import SwiftUI
import AVKit

struct A2UIVideoView: View {
    let properties: VideoProperties
    @Environment(SurfaceState.self) var surface
	@State private var player: AVPlayer?
	@State private var showFullscreen: Bool = false

    var body: some View {
		videoView
			.frame(minHeight: 200)
			.cornerRadius(8)
			.onAppear {
				if let urlString = surface.resolve(properties.url), let url = URL(string: urlString) {
					player = AVPlayer(url: url)
					player?.play()
				}
			}
			.fullScreenCover(isPresented: $showFullscreen) {
				videoView
			}
    }
	
	@ViewBuilder
	private var videoView: some View {
		VideoPlayer(player: player) {
			VStack {
				HStack {
					Image(systemName: showFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
						.padding(16)
						.foregroundStyle(.white)
						.tint(.white)
						.onTapGesture {
							showFullscreen.toggle()
						}
					
					Spacer()
				}
				Spacer()
			}
		}
	}
}
