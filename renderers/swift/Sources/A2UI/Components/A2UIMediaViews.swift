import SwiftUI
import AVKit

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

struct A2UIAudioPlayerView: View {
    let properties: AudioPlayerProperties
    @Environment(SurfaceState.self) var surface
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var volume: Double = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    togglePlay()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                
                Text("Audio Player")
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary)
                Slider(value: $volume, in: 0...1)
                    .onChange(of: volume) { _, newValue in
                        player?.volume = Float(newValue)
                    }
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .onAppear {
            if let urlString = surface.resolve(properties.url), let url = URL(string: urlString) {
                let avPlayer = AVPlayer(url: url)
                player = avPlayer
                volume = Double(avPlayer.volume)
            }
        }
    }

    private func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
}

struct A2UIDividerView: View {
    var body: some View {
        Divider()
            .padding(.vertical, 4)
    }
}

struct A2UIIconView: View {
    let properties: IconProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        if let name = surface.resolve(properties.name) {
			Image(systemName: A2UIIconName(rawValue: name)!.sfSymbolName)
                .font(.system(size: 24))
                .foregroundColor(.primary)
        }
    }

    private func mapToSFSymbol(_ name: String) -> String {
        return name
    }
}
