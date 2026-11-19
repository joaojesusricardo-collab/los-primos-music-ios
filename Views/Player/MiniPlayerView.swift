import SwiftUI

public struct MiniPlayerView: View {
    @ObservedObject private var player = AudioPlayerService.shared
    public let onTap: () -> Void

    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        if let song = player.currentSong {
            VStack(spacing: 0) {
                // Barra de progresso fina na borda superior
                GeometryReader { geo in
                    let progress = player.duration > 0 ? (player.currentTime / player.duration) : 0
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(LpColors.darkSurface3)
                            .frame(height: 2.5)

                        Rectangle()
                            .fill(LpColors.gold)
                            .frame(width: max(0, min(geo.size.width * CGFloat(progress), geo.size.width)), height: 2.5)
                    }
                }
                .frame(height: 2.5)

                HStack(spacing: LpDimensions.space12) {
                    // Capa pequena
                    AsyncImage(url: song.thumbnailUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LpColors.darkSurface3)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .foregroundColor(LpColors.gold)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    // Textos
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(LpTypography.titleMedium(14))
                            .foregroundColor(LpColors.textPrimary)
                            .lineLimit(1)

                        Text(song.artistNames)
                            .font(LpTypography.bodyRegular(12))
                            .foregroundColor(LpColors.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Botão Play/Pause
                    Button(action: {
                        player.togglePlayPause()
                    }) {
                        if player.isLoading {
                            ProgressView()
                                .tint(LpColors.gold)
                                .frame(width: 36, height: 36)
                        } else {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(LpColors.gold)
                                .frame(width: 36, height: 36)
                        }
                    }
                    .buttonStyle(.plain)

                    // Próxima Música
                    Button(action: {
                        player.skipToNext()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(LpColors.textSecondary)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, LpDimensions.space12)
                .padding(.vertical, LpDimensions.space8)
                .background(LpColors.gradientMiniPlayer)
            }
            .background(LpColors.darkSurface2)
            .cornerRadius(LpDimensions.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LpDimensions.cardRadius)
                    .stroke(LpColors.darkDivider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 4)
            .padding(.horizontal, LpDimensions.space8)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
    }
}
