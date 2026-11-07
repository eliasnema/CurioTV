import Foundation

public struct Channel: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let tier: Tier
    public let url: URL
    public let youtubeChannelID: String?
    public let username: String?
    public let featuredVideo: Video?

    public var feedURL: URL? {
        var components = URLComponents(string: "https://www.youtube.com/feeds/videos.xml")
        if let youtubeChannelID {
            components?.queryItems = [URLQueryItem(name: "channel_id", value: youtubeChannelID)]
        } else if let username {
            components?.queryItems = [URLQueryItem(name: "user", value: username)]
        } else { return nil }
        return components?.url
    }

    public func matches(_ query: String) -> Bool {
        let words = query.split(whereSeparator: \.isWhitespace)
        let searchable = "\(name) \(featuredVideo?.title ?? "")"
        return words.allSatisfy { searchable.localizedStandardContains(String($0)) }
    }
}
