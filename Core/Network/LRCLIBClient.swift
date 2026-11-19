import Foundation

public final class LRCLIBClient {
    public static let shared = LRCLIBClient()
    private let baseUrl = URL(string: "https://lrclib.net/api/")!

    private init() {}

    public func fetchLyrics(trackName: String, artistName: String, duration: Int? = nil) async -> SongLyrics? {
        var components = URLComponents(url: baseUrl.appendingPathComponent("get"), resolvingAgainstBaseURL: true)!
        var queryItems = [
            URLQueryItem(name: "track_name", value: trackName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]
        if let duration = duration {
            queryItems.append(URLQueryItem(name: "duration", value: "\(duration)"))
        }
        components.queryItems = queryItems

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("LosPrimosMusic-iOS/1.0", forHTTPHeaderField: "User-Agent")

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let syncedLyrics = json["syncedLyrics"] as? String, !syncedLyrics.isEmpty {
            let lines = parseLRC(syncedLyrics)
            return SongLyrics(isSynced: true, plainLyrics: nil, syncedLines: lines)
        } else if let plainLyrics = json["plainLyrics"] as? String, !plainLyrics.isEmpty {
            return SongLyrics(isSynced: false, plainLyrics: plainLyrics, syncedLines: [])
        }

        return nil
    }

    private func parseLRC(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let rawLines = lrc.components(separatedBy: .newlines)

        for line in rawLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("[") else { continue }

            let parts = trimmed.components(separatedBy: "]")
            guard parts.count >= 2 else { continue }

            let timeStr = parts[0].replacingOccurrences(of: "[", with: "")
            let text = parts.dropFirst().joined(separator: "]").trimmingCharacters(in: .whitespaces)

            // Formato mm:ss.xx ou mm:ss:xx
            let timeParts = timeStr.components(separatedBy: ":")
            if timeParts.count == 2,
               let mins = Double(timeParts[0]),
               let secs = Double(timeParts[1]) {
                let ms = Int((mins * 60 + secs) * 1000)
                lines.append(LyricLine(timeMs: ms, text: text))
            }
        }

        return lines.sorted { $0.timeMs < $1.timeMs }
    }
}
