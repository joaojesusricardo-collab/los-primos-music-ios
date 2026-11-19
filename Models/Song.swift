import Foundation

public struct Song: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let artists: [Artist]
    public let duration: TimeInterval?
    public let album: AlbumRef?
    public let thumbnailUrl: URL?
    public var streamUrl: URL?

    public init(
        id: String,
        title: String,
        artists: [Artist],
        duration: TimeInterval? = nil,
        album: AlbumRef? = nil,
        thumbnailUrl: URL? = nil,
        streamUrl: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.artists = artists
        self.duration = duration
        self.album = album
        self.thumbnailUrl = thumbnailUrl
        self.streamUrl = streamUrl
    }

    public var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
}

public struct Artist: Identifiable, Codable, Hashable {
    public let id: String?
    public let name: String

    public init(id: String? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

public struct AlbumRef: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public struct LyricLine: Identifiable, Codable, Hashable {
    public var id: Int { timeMs }
    public let timeMs: Int
    public let text: String

    public init(timeMs: Int, text: String) {
        self.timeMs = timeMs
        self.text = text
    }
}

public struct SongLyrics: Codable {
    public let isSynced: BooleanLiteralType
    public let plainLyrics: String?
    public let syncedLines: [LyricLine]

    public init(isSynced: Bool, plainLyrics: String? = nil, syncedLines: [LyricLine] = []) {
        self.isSynced = isSynced
        self.plainLyrics = plainLyrics
        self.syncedLines = syncedLines
    }
}
