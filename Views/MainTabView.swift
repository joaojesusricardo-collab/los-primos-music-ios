import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var isShowingFullPlayer = false
    @ObservedObject private var player = AudioPlayerService.shared

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Conteúdo Principal da TabView
            TabView(selection: $selectedTab) {
                HomeView(onSelectSearch: { query in
                    selectedTab = 1
                })
                .tag(0)
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }

                SearchView()
                    .tag(1)
                    .tabItem {
                        Label("Buscar", systemImage: "magnifyingglass")
                    }

                LibraryView()
                    .tag(2)
                    .tabItem {
                        Label("Biblioteca", systemImage: "music.note.list")
                    }
            }
            .tint(LpColors.gold)

            // Miniplayer flutuante acima da Tab Bar quando houver música tocando
            if player.currentSong != nil {
                MiniPlayerView {
                    isShowingFullPlayer = true
                }
                .padding(.bottom, 50) // Altura padrão da barra de abas do iOS
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $isShowingFullPlayer) {
            FullPlayerView()
        }
    }
}
