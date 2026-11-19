import SwiftUI

public struct LyricsView: View {
    public let song: Song
    public let currentTimeMs: Int

    @State private var lyrics: SongLyrics?
    @State private var isLoading = true

    public init(song: Song, currentTimeMs: Int) {
        self.song = song
        self.currentTimeMs = currentTimeMs
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: LpDimensions.space16) {
                    if isLoading {
                        ProgressView()
                            .tint(LpColors.gold)
                            .padding(.top, 40)
                    } else if let lyrics = lyrics {
                        if lyrics.isSynced {
                            ForEach(lyrics.syncedLines) { line in
                                let isCurrent = isLineActive(line: line, allLines: lyrics.syncedLines)

                                Text(line.text)
                                    .font(isCurrent ? LpTypography.titleHero(22) : LpTypography.titleMedium(18))
                                    .foregroundColor(isCurrent ? LpColors.goldLight : LpColors.textSecondary.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                                    .id(line.timeMs)
                                    .animation(.easeInOut(duration: 0.25), value: isCurrent)
                            }
                        } else if let plain = lyrics.plainLyrics {
                            Text(plain)
                                .font(LpTypography.bodyMedium(16))
                                .foregroundColor(LpColors.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal, LpDimensions.space20)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "music.mic")
                                .font(.system(size: 40))
                                .foregroundColor(LpColors.textSecondary)
                            Text("Letra indisponível para esta música")
                                .font(LpTypography.bodyMedium(15))
                                .foregroundColor(LpColors.textSecondary)
                        }
                        .padding(.top, 60)
                    }
                }
                .padding(.vertical, LpDimensions.space32)
            }
            .onChange(of: currentTimeMs) { newTime in
                if let currentLine = lyrics?.syncedLines.last(where: { $0.timeMs <= newTime }) {
                    withAnimation {
                        proxy.scrollTo(currentLine.timeMs, anchor: .center)
                    }
                }
            }
            .task {
                await loadLyrics()
            }
        }
    }

    private func isLineActive(line: LyricLine, allLines: [LyricLine]) -> Bool {
        guard let index = allLines.firstIndex(where: { $0.timeMs == line.timeMs }) else { return false }
        let nextTime = index + 1 < allLines.count ? allLines[index + 1].timeMs : Int.max
        return currentTimeMs >= line.timeMs && currentTimeMs < nextTime
    }

    private func loadLyrics() async {
        isLoading = true
        let trackName = song.title
        let artistName = song.artistNames
        let duration = song.duration != nil ? Int(song.duration!) : nil

        self.lyrics = await LRCLIBClient.shared.fetchLyrics(
            trackName: trackName,
            artistName: artistName,
            duration: duration
        )
        isLoading = false
    }
}
