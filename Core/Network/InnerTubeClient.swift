import Foundation

public final class InnerTubeClient {
    public static let shared = InnerTubeClient()

    private let session: URLSession
    private let baseUrl = URL(string: "https://music.youtube.com/youtubei/v1/")!

    // Clientes configurados
    private let webRemixApiKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"
    private let visionOSApiKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"

    private let userAgentWeb = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    private let userAgentVisionOS = "com.google.visionos.youtube/1.04(RealityDevice17,1; U; CPU visionOS 26_6_0 like Mac OS X; US)"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Search
    public func search(query: String) async throws -> [Song] {
        var components = URLComponents(url: baseUrl.appendingPathComponent("search"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "key", value: webRemixApiKey),
            URLQueryItem(name: "prettyPrint", value: "false")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Origin")
        request.setValue("https://music.youtube.com/", forHTTPHeaderField: "Referer")
        request.setValue(userAgentWeb, forHTTPHeaderField: "User-Agent")
        request.setValue("67", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.setValue("1.20261115.14.00", forHTTPHeaderField: "X-YouTube-Client-Version")

        let body: [String: Any] = [
            "context": [
                "client": [
                    "clientName": "WEB_REMIX",
                    "clientVersion": "1.20261115.14.00",
                    "gl": "BR",
                    "hl": "pt-BR"
                ]
            ],
            "query": query,
            // Filtro para buscar músicas prioritariamente
            "params": "Eg-KAQwIARAAGAAgACgAMABqChAEEAMQCRAFEAo%3D"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return parseSearchSongs(from: data)
    }

    // MARK: - Get Stream URL (via VISIONOS Client)
    public func fetchStreamUrl(videoId: String) async throws -> URL {
        var components = URLComponents(url: baseUrl.appendingPathComponent("player"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "key", value: visionOSApiKey),
            URLQueryItem(name: "prettyPrint", value: "false")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Origin")
        request.setValue("https://music.youtube.com/", forHTTPHeaderField: "Referer")
        request.setValue(userAgentVisionOS, forHTTPHeaderField: "User-Agent")
        request.setValue("101", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.setValue("1.04", forHTTPHeaderField: "X-YouTube-Client-Version")

        let body: [String: Any] = [
            "context": [
                "client": [
                    "clientName": "VISIONOS",
                    "clientVersion": "1.04",
                    "osVersion": "26.6.0.23O770",
                    "gl": "BR",
                    "hl": "pt-BR"
                ]
            ],
            "videoId": videoId
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let streamingData = json["streamingData"] as? [String: Any],
              let formats = streamingData["adaptiveFormats"] as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }

        // Filtra por formatos de áudio diretos (mimeType começa com "audio/")
        let audioFormats = formats.filter {
            ($0["mimeType"] as? String)?.hasPrefix("audio/") == true && $0["url"] != nil
        }

        // Prioriza m4a / aac ou o maior bitrate médio
        let bestFormat = audioFormats.max { (a, b) -> Bool in
            let bitA = a["bitrate"] as? Int ?? 0
            let bitB = b["bitrate"] as? Int ?? 0
            return bitA < bitB
        }

        guard let urlString = bestFormat?["url"] as? String, let directUrl = URL(string: urlString) else {
            throw URLError(.resourceUnavailable)
        }

        return directUrl
    }

    // MARK: - Parsing Helpers
    private func parseSearchSongs(from data: Data) -> [Song] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }

        // Navegação pelo payload do InnerTube
        guard let contents = json["contents"] as? [String: Any],
              let tabbedResults = contents["tabbedSearchResultsRenderer"] as? [String: Any],
              let tabs = tabbedResults["tabs"] as? [[String: Any]],
              let firstTab = tabs.first,
              let tabContent = firstTab["tabRenderer"] as? [String: Any],
              let content = tabContent["content"] as? [String: Any],
              let sectionList = content["sectionListRenderer"] as? [String: Any],
              let sections = sectionList["contents"] as? [[String: Any]] else {
            return []
        }

        var songs: [Song] = []

        for section in sections {
            guard let musicShelf = section["musicShelfRenderer"] as? [String: Any],
                  let items = musicShelf["contents"] as? [[String: Any]] else {
                continue
            }

            for item in items {
                guard let renderer = item["musicResponsiveListItemRenderer"] as? [String: Any] else { continue }

                // Extrair VideoId
                let playNav = renderer["overlay"] as? [String: Any]
                let musicPlayButton = (playNav?["musicItemThumbnailOverlayRenderer"] as? [String: Any])?["content"] as? [String: Any]
                let playEndpoint = (musicPlayButton?["musicPlayButtonRenderer"] as? [String: Any])?["playNavigationEndpoint"] as? [String: Any]
                let watchEndpoint = playEndpoint?["watchEndpoint"] as? [String: Any]
                let videoId = watchEndpoint?["videoId"] as? String ?? ""

                if videoId.isEmpty { continue }

                // Extrair Título
                let flexColumns = renderer["flexColumns"] as? [[String: Any]] ?? []
                var title = "Desconhecido"
                var artists: [Artist] = []
                var albumRef: AlbumRef?

                if let firstCol = flexColumns.first,
                   let textRuns = ((firstCol["musicResponsiveListItemFlexColumnRenderer"] as? [String: Any])?["text"] as? [String: Any])?["runs"] as? [[String: Any]],
                   let firstRun = textRuns.first {
                    title = firstRun["text"] as? String ?? "Desconhecido"
                }

                // Extrair Artista / Álbum da segunda coluna
                if flexColumns.count > 1,
                   let secondCol = flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"] as? [String: Any],
                   let textRuns = (secondCol["text"] as? [String: Any])?["runs"] as? [[String: Any]] {
                    for run in textRuns {
                        let text = run["text"] as? String ?? ""
                        if text == " • " || text.trimmingCharacters(in: .whitespaces).isEmpty { continue }

                        if let nav = run["navigationEndpoint"] as? [String: Any],
                           let browse = nav["browseEndpoint"] as? [String: Any],
                           let browseId = browse["browseId"] as? String {
                            if browseId.hasPrefix("UC") {
                                artists.append(Artist(id: browseId, name: text))
                            } else if browseId.hasPrefix("MPRE") || browseId.hasPrefix("FEx") {
                                albumRef = AlbumRef(id: browseId, title: text)
                            }
                        } else if artists.isEmpty {
                            artists.append(Artist(name: text))
                        }
                    }
                }

                // Extrair Thumbnail
                var thumbUrl: URL?
                if let thumbnailRenderer = renderer["thumbnail"] as? [String: Any],
                   let musicThumb = thumbnailRenderer["musicThumbnailRenderer"] as? [String: Any],
                   let thumbObj = musicThumb["thumbnail"] as? [String: Any],
                   let thumbs = thumbObj["thumbnails"] as? [[String: Any]],
                   let lastThumb = thumbs.last,
                   let urlString = lastThumb["url"] as? String {
                    thumbUrl = URL(string: urlString)
                }

                songs.append(Song(
                    id: videoId,
                    title: title,
                    artists: artists.isEmpty ? [Artist(name: "Vários Artistas")] : artists,
                    album: albumRef,
                    thumbnailUrl: thumbUrl
                ))
            }
        }

        return songs
    }
}
