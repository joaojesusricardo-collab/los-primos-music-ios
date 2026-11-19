import SwiftUI

public struct FullPlayerView: View {
    @ObservedObject private var player = AudioPlayerService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingLyrics = false
    @State private var isDraggingSlider = false
    @State private var dragTime: TimeInterval = 0

    public init() {}

    public var body: some View {
        ZStack {
            // Fundo escuro com gradiente Los Primos
            LpColors.gradientPlayerFallback
                .ignoresSafeArea()

            VStack(spacing: LpDimensions.space20) {
                // Barra Superior
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(LpColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Reproduzindo")
                        .font(LpTypography.titleMedium(16))
                        .foregroundColor(LpColors.textSecondary)

                    Spacer()

                    Button(action: { isShowingLyrics.toggle() }) {
                        Image(systemName: isShowingLyrics ? "music.note" : "quote.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(isShowingLyrics ? LpColors.gold : LpColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, LpDimensions.space16)

                if let song = player.currentSong {
                    if isShowingLyrics {
                        LyricsView(song: song, currentTimeMs: Int(player.currentTime * 1000))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Spacer()

                        // Capa da Música
                        AsyncImage(url: song.thumbnailUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure, .empty:
                                RoundedRectangle(cornerRadius: LpDimensions.coverRadius)
                                    .fill(LpColors.darkSurface3)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 80))
                                            .foregroundColor(LpColors.goldSoft)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: 320, maxHeight: 320)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: LpDimensions.coverRadius))
                        .shadow(color: Color.black.opacity(0.6), radius: 25, x: 0, y: 12)
                        .padding(.horizontal, LpDimensions.space24)

                        Spacer()

                        // Metadados (Título e Artista)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(song.title)
                                .font(LpTypography.titleHero(22))
                                .foregroundColor(LpColors.textPrimary)
                                .lineLimit(1)

                            Text(song.artistNames)
                                .font(LpTypography.bodyMedium(16))
                                .foregroundColor(LpColors.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, LpDimensions.space24)

                        // Slider de Progresso
                        VStack(spacing: 6) {
                            let effectiveTime = isDraggingSlider ? dragTime : player.currentTime
                            let duration = max(player.duration, 1)

                            Slider(
                                value: Binding(
                                    get: { effectiveTime },
                                    set: { newValue in
                                        dragTime = newValue
                                        isDraggingSlider = true
                                    }
                                ),
                                in: 0...duration,
                                onEditingChanged: { editing in
                                    if !editing {
                                        player.seek(to: dragTime)
                                        isDraggingSlider = false
                                    }
                                }
                            )
                            .tint(LpColors.gold)

                            HStack {
                                Text(formatTime(effectiveTime))
                                    .font(LpTypography.caption(12))
                                    .foregroundColor(LpColors.textSecondary)

                                Spacer()

                                Text(formatTime(duration))
                                    .font(LpTypography.caption(12))
                                    .foregroundColor(LpColors.textSecondary)
                            }
                        }
                        .padding(.horizontal, LpDimensions.space24)

                        // Controles de Reprodução
                        HStack(spacing: LpDimensions.space32) {
                            // Shuffle
                            Button(action: { player.isShuffleEnabled.toggle() }) {
                                Image(systemName: "shuffle")
                                    .font(.system(size: 20))
                                    .foregroundColor(player.isShuffleEnabled ? LpColors.gold : LpColors.textSecondary)
                            }

                            // Anterior
                            Button(action: { player.skipToPrevious() }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(LpColors.textPrimary)
                            }

                            // Play / Pause Principal
                            BrandPlayPauseButton(
                                isPlaying: player.isPlaying,
                                isLoading: player.isLoading,
                                size: 72,
                                action: { player.togglePlayPause() }
                            )

                            // Próxima
                            Button(action: { player.skipToNext() }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(LpColors.textPrimary)
                            }

                            // Repeat
                            Button(action: { player.isRepeatEnabled.toggle() }) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 20))
                                    .foregroundColor(player.isRepeatEnabled ? LpColors.gold : LpColors.textSecondary)
                            }
                        }
                        .padding(.vertical, LpDimensions.space16)
                    }
                }
            }
            .padding(.top, LpDimensions.space12)
            .padding(.bottom, LpDimensions.space24)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
