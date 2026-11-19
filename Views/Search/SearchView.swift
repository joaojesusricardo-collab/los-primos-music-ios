import SwiftUI

public struct SearchView: View {
    @State private var query = ""
    @State private var searchResults: [Song] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @ObservedObject private var player = AudioPlayerService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LpColors.darkBackground
                    .ignoresSafeArea()

                VStack(spacing: LpDimensions.space16) {
                    // Barra de Busca Los Primos
                    HStack(spacing: LpDimensions.space12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(LpColors.gold)
                            .font(.system(size: 18))

                        TextField("", text: $query, prompt: Text("O que você quer ouvir?").foregroundColor(LpColors.textTertiary))
                            .foregroundColor(LpColors.textPrimary)
                            .font(LpTypography.bodyMedium(16))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .submitLabel(.search)
                            .onSubmit {
                                Task { await performSearch() }
                            }

                        if !query.isEmpty {
                            Button(action: {
                                query = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(LpColors.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, LpDimensions.space16)
                    .padding(.vertical, LpDimensions.space12)
                    .background(LpColors.darkSurface2)
                    .cornerRadius(LpDimensions.chipRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: LpDimensions.chipRadius)
                            .stroke(LpColors.darkDivider, lineWidth: 1)
                    )
                    .padding(.horizontal, LpDimensions.space16)
                    .padding(.top, LpDimensions.space8)

                    // Área de Resultados / Estados
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(LpColors.gold)
                            .scaleEffect(1.2)
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 36))
                                .foregroundColor(LpColors.wine)
                            Text(error)
                                .font(LpTypography.bodyMedium(15))
                                .foregroundColor(LpColors.textSecondary)
                        }
                        Spacer()
                    } else if searchResults.isEmpty && !query.isEmpty {
                        Spacer()
                        Text("Nenhum resultado encontrado")
                            .font(LpTypography.bodyMedium(15))
                            .foregroundColor(LpColors.textSecondary)
                        Spacer()
                    } else if searchResults.isEmpty {
                        Spacer()
                        VStack(spacing: LpDimensions.space12) {
                            Image(systemName: "music.note.magnifyingglass")
                                .font(.system(size: 54))
                                .foregroundColor(LpColors.darkSurface3)
                            Text("Busque músicas, artistas ou álbuns")
                                .font(LpTypography.titleMedium(16))
                                .foregroundColor(LpColors.textSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, song in
                                    SongRowView(
                                        song: song,
                                        isCurrent: player.currentSong?.id == song.id
                                    ) {
                                        player.play(song: song)
                                        // Adicionar as seguintes à fila
                                        let following = Array(searchResults.dropFirst(index + 1))
                                        for nextSong in following {
                                            player.addToQueue(nextSong)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 90) // Espaço para o miniplayer
                        }
                    }
                }
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LpColors.darkBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            self.searchResults = try await InnerTubeClient.shared.search(query: trimmed)
        } catch {
            self.errorMessage = "Erro ao buscar músicas. Verifique a conexão."
        }

        isLoading = false
    }
}
