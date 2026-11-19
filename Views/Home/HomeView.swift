import SwiftUI

public struct HomeView: View {
    @ObservedObject private var player = AudioPlayerService.shared
    @State private var quickPicks: [Song] = []
    @State private var isLoading = false

    public let onSelectSearch: (String) -> Void

    public init(onSelectSearch: @escaping (String) -> Void = { _ in }) {
        self.onSelectSearch = onSelectSearch
    }

    private let categories = [
        ("Top Brasil", "flame.fill"),
        ("Sertanejo", "guitars.fill"),
        ("Trap Brasil", "bolt.fill"),
        ("Pagode & Samba", "party.popper.fill"),
        ("Eletrônica", "waveform.path.ecg")
    ]

    public var body: some View {
        NavigationStack {
            ZStack {
                LpColors.darkBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: LpDimensions.space24) {
                        // Header com Logo Los Primos
                        HStack(spacing: LpDimensions.space12) {
                            Image("los_primos_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 38)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("LOS PRIMOS")
                                    .font(LpTypography.titleHero(20))
                                    .foregroundColor(LpColors.goldLight)
                                Text("Música sem limites")
                                    .font(LpTypography.caption(12))
                                    .foregroundColor(LpColors.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, LpDimensions.space16)
                        .padding(.top, LpDimensions.space8)

                        // Banner de Destaque
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: LpDimensions.heroRadius)
                                .fill(LpColors.gradientBrand)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ouça agora")
                                    .font(LpTypography.caption(12))
                                    .foregroundColor(LpColors.goldSoft)
                                    .textCase(.uppercase)

                                Text("Músicas em Alta no Brasil")
                                    .font(LpTypography.titleHero(22))
                                    .foregroundColor(.white)

                                Button(action: {
                                    onSelectSearch("Top Brasil 2026")
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "play.fill")
                                        Text("Explorar")
                                    }
                                    .font(LpTypography.titleMedium(14))
                                    .foregroundColor(LpColors.darkBackground)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(LpColors.goldLight)
                                    .cornerRadius(20)
                                }
                                .padding(.top, 4)
                            }
                            .padding(LpDimensions.space20)
                        }
                        .frame(height: 160)
                        .padding(.horizontal, LpDimensions.space16)

                        // Gêneros e Categorias Rápidas
                        VStack(alignment: .leading, spacing: LpDimensions.space12) {
                            Text("Gêneros Populares")
                                .font(LpTypography.titleSection(18))
                                .foregroundColor(LpColors.textPrimary)
                                .padding(.horizontal, LpDimensions.space16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: LpDimensions.space12) {
                                    ForEach(categories, id: \.0) { category in
                                        Button(action: {
                                            onSelectSearch(category.0)
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: category.1)
                                                    .foregroundColor(LpColors.gold)
                                                Text(category.0)
                                                    .font(LpTypography.titleMedium(14))
                                                    .foregroundColor(LpColors.textPrimary)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(LpColors.darkSurface2)
                                            .cornerRadius(LpDimensions.chipRadius)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: LpDimensions.chipRadius)
                                                    .stroke(LpColors.darkDivider, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, LpDimensions.space16)
                            }
                        }

                        // Músicas Recomendadas
                        if !quickPicks.isEmpty {
                            VStack(alignment: .leading, spacing: LpDimensions.space12) {
                                Text("Recomendações Rápidas")
                                    .font(LpTypography.titleSection(18))
                                    .foregroundColor(LpColors.textPrimary)
                                    .padding(.horizontal, LpDimensions.space16)

                                LazyVStack(spacing: 4) {
                                    ForEach(quickPicks) { song in
                                        SongRowView(
                                            song: song,
                                            isCurrent: player.currentSong?.id == song.id
                                        ) {
                                            player.play(song: song)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .task {
                if quickPicks.isEmpty {
                    if let results = try? await InnerTubeClient.shared.search(query: "Top Brasil"), !results.isEmpty {
                        self.quickPicks = Array(results.prefix(8))
                    }
                }
            }
        }
    }
}
