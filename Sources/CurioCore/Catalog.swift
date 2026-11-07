import Foundation

public struct Catalog: Codable, Sendable {
    public let sourceURL: URL
    public let attribution: String
    public let importedAt: String
    public let channels: [Channel]

    public static func load() throws -> Catalog {
        guard let url = Bundle.module.url(forResource: "channels", withExtension: "json") else {
            throw CatalogError.missingResource
        }
        let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
        try catalog.validate()
        return catalog
    }

    public func validate() throws {
        guard !channels.isEmpty, Set(channels.map(\.id)).count == channels.count else {
            throw CatalogError.invalidChannels
        }
        for channel in channels {
            guard !channel.name.isEmpty, channel.url.scheme == "https", channel.url.host == "www.youtube.com" else {
                throw CatalogError.invalidChannels
            }
            if let video = channel.featuredVideo {
                guard YouTubeLink.isValidVideoID(video.id), video.channelID == channel.id else {
                    throw CatalogError.invalidVideo
                }
            }
        }
    }
}

public enum CatalogError: Error {
    case missingResource, invalidChannels, invalidVideo
}
