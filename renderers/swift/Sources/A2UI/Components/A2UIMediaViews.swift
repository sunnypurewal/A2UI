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
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    togglePlay()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                
                VStack(alignment: .leading) {
                    Text(surface.resolve(properties.description) ?? "Audio Player")
                        .font(.caption)
                    
                    Slider(value: $currentTime, in: 0...max(duration, 0.01)) { editing in
                        isEditing = editing
                        if !editing {
                            player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
                        }
                    }
                    
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                }
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
            setupPlayer()
        }
		.onChange(of: surface.dataModel.count) { oldValue, newValue in
			print("Audio Player data model changed from \(oldValue) to \(newValue)")
		}
    }

    private func setupPlayer() {
        if let urlString = surface.resolve(properties.url), let url = URL(string: urlString) {
            let avPlayer = AVPlayer(url: url)
            player = avPlayer
            volume = Double(avPlayer.volume)
            isPlaying = false
            currentTime = 0
            duration = 0
            
            // Observe time
            avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
                Task { @MainActor in
                    if !isEditing {
                        currentTime = time.seconds
                    }
                }
            }
            
            // Observe duration
            Task {
                if let duration = try? await avPlayer.currentItem?.asset.load(.duration) {
                    self.duration = duration.seconds
                }
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
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
