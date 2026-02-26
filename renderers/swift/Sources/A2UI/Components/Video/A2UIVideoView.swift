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
            .onDisappear {
                player?.pause()
                player = nil
            }
			#if os(iOS)
			                    .fullScreenCover(isPresented: $showFullscreen) {
			                            videoView
			                    }
			#endif
			
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

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    A2UIVideoView(properties: VideoProperties(
        url: .init(literal: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
