import SwiftUI

public struct LibraryView: View {
    @ObservedObject private var player = AudioPlayerService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LpColors.darkBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: LpDimensions.space20) {
                        // Seção de Fila Atual
                        if !player.queue.isEmpty {
                            VStack(alignment: .leading, spacing: LpDimensions.space12) {
                                Text("A Seguir na Fila (\(player.queue.count))")
                                    .font(LpTypography.titleSection(18))
                                    .foregroundColor(LpColors.textPrimary)
                                    .padding(.horizontal, LpDimensions.space16)

                                LazyVStack(spacing: 4) {
                                    ForEach(Array(player.queue.enumerated()), id: \.offset) { index, song in
                                        SongRowView(song: song, isCurrent: false) {
                                            player.play(song: song)
                                        }
                                    }
                                }
                            }
                        }

                        // Informações do App
                        VStack(spacing: LpDimensions.space12) {
                            Image("los_primos_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 60)
                                .padding(.top, 20)

                            Text("Los Primos Music iOS")
                                .font(LpTypography.titleHero(18))
                                .foregroundColor(LpColors.goldLight)

                            Text("Versão 1.0.0 (Uso Privado)")
                                .font(LpTypography.caption(13))
                                .foregroundColor(LpColors.textSecondary)

                            Text("Reprodução de alta fidelidade sem anúncios com streaming direto e integração com tela de bloqueio do iOS.")
                                .font(LpTypography.bodyRegular(13))
                                .foregroundColor(LpColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LpDimensions.space24)
                        .background(LpColors.darkSurface1)
                        .cornerRadius(LpDimensions.cardRadius)
                        .padding(.horizontal, LpDimensions.space16)
                    }
                    .padding(.top, LpDimensions.space16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Biblioteca")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LpColors.darkBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
