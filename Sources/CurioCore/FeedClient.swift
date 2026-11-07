import Foundation

public enum FeedError: Error, LocalizedError {
    case unavailable, invalidFeed, noFeed, responseTooLarge

    public var errorDescription: String? {
        switch self {
        case .unavailable: "YouTube's recent uploads are unavailable. Try again in a moment."
        case .invalidFeed: "YouTube returned an unreadable feed. The article pick is still available."
        case .noFeed: "Recent uploads are unavailable for this channel. Open the channel in YouTube instead."
        case .responseTooLarge: "The channel feed was too large to load."
        }
    }
}

public actor FeedClient {
    private struct Cached: Sendable {
        let videos: [Video]
        let date: Date
    }
    private let session: URLSession
    private var cache: [String: Cached] = [:]

    public init(session: URLSession = .shared) { self.session = session }

    public func videos(for channel: Channel, forceRefresh: Bool = false) async throws -> [Video] {
        if !forceRefresh, let cached = cache[channel.id], Date().timeIntervalSince(cached.date) < 600 {
            return cached.videos
        }
        guard let url = channel.feedURL else { throw FeedError.noFeed }
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("application/atom+xml, application/xml", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FeedError.unavailable }
        guard data.count < 2_000_000 else { throw FeedError.responseTooLarge }
        let videos = try FeedParser.parse(data, channel: channel)
        cache[channel.id] = Cached(videos: videos, date: .now)
        return videos
    }
}
