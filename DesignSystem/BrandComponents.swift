import SwiftUI

// MARK: - Botão de Play/Pause Principal
public struct BrandPlayPauseButton: View {
    public let isPlaying: Bool
    public let isLoading: Bool
    public let size: CGFloat
    public let action: () -> Void

    public init(isPlaying: Bool, isLoading: Bool = false, size: CGFloat = 64, action: @escaping () -> Void) {
        self.isPlaying = isPlaying
        self.isLoading = isLoading
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(LpColors.gradientPrimary)
                    .frame(width: size, height: size)
                    .shadow(color: LpColors.gold.opacity(0.35), radius: 8, x: 0, y: 4)

                if isLoading {
                    ProgressView()
                        .tint(LpColors.darkBackground)
                } else {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: size * 0.42, weight: .bold))
                        .foregroundColor(LpColors.darkBackground)
                        .offset(x: isPlaying ? 0 : 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Linha de Música (Lista de Busca / Fila)
public struct SongRowView: View {
    public let song: Song
    public let isCurrent: Bool
    public let onSelect: () -> Void

    public init(song: Song, isCurrent: Bool = false, onSelect: @escaping () -> Void) {
        self.song = song
        self.isCurrent = isCurrent
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: LpDimensions.space12) {
                // Thumbnail
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
                                    .foregroundColor(LpColors.goldSoft)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // Detalhes da Música
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(LpTypography.titleMedium(15))
                        .foregroundColor(isCurrent ? LpColors.goldLight : LpColors.textPrimary)
                        .lineLimit(1)

                    Text(song.artistNames)
                        .font(LpTypography.bodyRegular(13))
                        .foregroundColor(LpColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if isCurrent {
                    Image(systemName: "waveform")
                        .foregroundColor(LpColors.gold)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(.horizontal, LpDimensions.space16)
            .padding(.vertical, LpDimensions.space8)
            .background(isCurrent ? LpColors.darkSurface2.opacity(0.6) : Color.clear)
            .cornerRadius(LpDimensions.cardRadius)
        }
        .buttonStyle(.plain)
    }
}
