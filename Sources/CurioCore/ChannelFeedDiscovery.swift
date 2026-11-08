import Foundation

public actor ChannelFeedDiscovery {
    private let session = URLSession(configuration: .ephemeral)

    public init() {}

    /// Follows the public RSS link advertised by a channel's HTML page. No account or private API is used.
    public func discover(for channel: Channel) async -> Channel {
        guard channel.feedURL == nil, (try? ChannelAddress(channel.url.absoluteString)) != nil else { return channel }
        var request = URLRequest(url: channel.url)
        request.timeoutInterval = 15
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await session.data(for: request)
            try Task.checkCancellation()
            guard let response = response as? HTTPURLResponse, response.statusCode == 200,
                  response.url?.host == "www.youtube.com", data.count < 3_000_000,
                  let html = String(data: data, encoding: .utf8),
                  let id = Self.advertisedChannelID(in: html) else { return channel }
            return Channel(id: id, name: channel.name, tier: channel.tier, url: channel.url,
                           youtubeChannelID: id, featuredVideo: channel.featuredVideo)
        } catch { return channel }
    }

    public static func advertisedChannelID(in html: String) -> String? {
        guard let links = try? NSRegularExpression(pattern: #"<link\b[^>]{0,10000}>"#, options: .caseInsensitive),
              let href = try? NSRegularExpression(pattern: #"\bhref\s*=\s*["']([^"']+)["']"#, options: .caseInsensitive) else { return nil }
        for match in links.matches(in: html, range: NSRange(html.startIndex..., in: html)) {
            guard let range = Range(match.range, in: html) else { continue }
            let tag = String(html[range])
            guard tag.localizedCaseInsensitiveContains("application/rss+xml"),
                  let attribute = href.firstMatch(in: tag, range: NSRange(tag.startIndex..., in: tag)),
                  let value = Range(attribute.range(at: 1), in: tag),
                  let url = URLComponents(string: String(tag[value]).replacingOccurrences(of: "&amp;", with: "&")),
                  url.scheme == "https", url.host == "www.youtube.com", url.path == "/feeds/videos.xml",
                  let id = url.queryItems?.first(where: { $0.name == "channel_id" })?.value,
                  id.range(of: #"^UC[A-Za-z0-9_-]{22}$"#, options: .regularExpression) != nil else { continue }
            return id
        }
        return nil
    }
}
