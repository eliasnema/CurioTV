import Foundation

public struct Video: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let channelID: String
    public let channelName: String
    public let publishedAt: Date?
    public let isShort: Bool

    public init(id: String, title: String, channelID: String, channelName: String,
                publishedAt: Date? = nil, isShort: Bool = false) {
        self.id = id
        self.title = title
        self.channelID = channelID
        self.channelName = channelName
        self.publishedAt = publishedAt
        self.isShort = isShort
    }

    public var thumbnailURL: URL? { URL(string: "https://i.ytimg.com/vi/\(id)/hqdefault.jpg") }
    public var watchURL: URL? { YouTubeLink.video(id: id, scheme: "https") }
    public var appURL: URL? { YouTubeLink.video(id: id, scheme: "youtube") }
}
