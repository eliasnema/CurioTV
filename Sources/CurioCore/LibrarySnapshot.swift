import Foundation

public struct LibrarySnapshot: Codable, Equatable, Sendable {
    public private(set) var savedVideos: [Video] = []
    public private(set) var favoriteChannelIDs: Set<String> = []
    public private(set) var openings: [VideoOpening] = []

    public init() {}

    public mutating func toggleSaved(_ video: Video) {
        if savedVideos.contains(where: { $0.id == video.id }) {
            savedVideos.removeAll { $0.id == video.id }
        } else { savedVideos.insert(video, at: 0) }
    }

    public mutating func toggleFavorite(_ channelID: String) {
        if !favoriteChannelIDs.insert(channelID).inserted { favoriteChannelIDs.remove(channelID) }
    }

    public mutating func recordOpening(_ video: Video, at date: Date = .now) {
        openings.removeAll { $0.video.id == video.id }
        openings.insert(VideoOpening(video: video, openedAt: date), at: 0)
        openings = Array(openings.prefix(40))
    }

    public mutating func clearOpenings() { openings = [] }
}

public struct VideoOpening: Codable, Equatable, Identifiable, Sendable {
    public var id: String { video.id }
    public let video: Video
    public let openedAt: Date
}
