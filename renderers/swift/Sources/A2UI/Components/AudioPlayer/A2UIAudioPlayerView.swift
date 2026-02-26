import SwiftUI
import AVKit

struct A2UIAudioPlayerView: View {
    let properties: AudioPlayerProperties
    @Environment(SurfaceState.self) var surface
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var volume: Double = 1.0
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isEditing: Bool = false
    @State private var timeObserverToken: Any?

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
        .onDisappear {
            if let token = timeObserverToken {
                player?.removeTimeObserver(token)
                timeObserverToken = nil
            }
            player?.pause()
            player = nil
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
            timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
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

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    A2UIAudioPlayerView(properties: AudioPlayerProperties(
        url: .init(literal: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
        description: .init(literal: "Sample Audio")
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
