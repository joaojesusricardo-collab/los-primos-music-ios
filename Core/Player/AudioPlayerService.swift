import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor
public final class AudioPlayerService: ObservableObject {
    public static let shared = AudioPlayerService()

    @Published public private(set) var currentSong: Song?
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var queue: [Song] = []
    @Published public var isShuffleEnabled: Bool = false
    @Published public var isRepeatEnabled: Bool = false

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    // MARK: - Audio Session Setup (Background Audio)
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("[AudioPlayerService] Erro ao configurar AVAudioSession: \(error.localizedDescription)")
        }
    }

    // MARK: - Playback Control
    public func play(song: Song) {
        if currentSong?.id == song.id && player != nil {
            resume()
            return
        }

        self.currentSong = song
        self.isLoading = true
        self.isPlaying = false
        self.currentTime = 0
        self.duration = song.duration ?? 0

        Task {
            do {
                let streamUrl = try await InnerTubeClient.shared.fetchStreamUrl(videoId: song.id)
                self.setupPlayer(with: streamUrl, for: song)
            } catch {
                print("[AudioPlayerService] Erro ao obter stream URL: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }

    private func setupPlayer(with url: URL, for song: Song) {
        // Limpar player anterior
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.skipToNext()
        }

        self.player = AVPlayer(playerItem: playerItem)

        // Observar tempo atual
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let itemDuration = self.player?.currentItem?.duration.seconds, !itemDuration.isNaN, itemDuration > 0 {
                self.duration = itemDuration
            }
            self.updateNowPlayingInfo()
        }

        self.player?.play()
        self.isPlaying = true
        self.isLoading = false
        self.updateNowPlayingInfo()
    }

    public func resume() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    public func seek(to seconds: TimeInterval) {
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.updateNowPlayingInfo()
        }
    }

    public func skipToNext() {
        guard !queue.isEmpty else { return }
        let nextSong = queue.removeFirst()
        play(song: nextSong)
    }

    public func skipToPrevious() {
        if currentTime > 3.0 {
            seek(to: 0)
        } else {
            seek(to: 0)
        }
    }

    public func addToQueue(_ song: Song) {
        queue.append(song)
    }

    // MARK: - Lock Screen & Control Center (MPNowPlayingInfoCenter)
    private func updateNowPlayingInfo() {
        guard let song = currentSong else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artistNames,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration > 0 ? duration : (song.duration ?? 0),
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let albumTitle = song.album?.title {
            info[MPMediaItemPropertyAlbumTitle] = albumTitle
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.skipToNext()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.skipToPrevious()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.seek(to: positionEvent.positionTime)
            return .success
        }
    }
}
