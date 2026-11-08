import Foundation

public struct ChannelAddress: Equatable, Sendable {
    public let url: URL
    public let id: String
    public let youtubeChannelID: String?
    public let username: String?

    public init(_ input: String) throws {
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("@") { text = "https://www.youtube.com/\(text)" }
        if text.hasPrefix("UC"), text.count == 24 { text = "https://www.youtube.com/channel/\(text)" }
        if text.hasPrefix("youtube.com/") || text.hasPrefix("www.youtube.com/") { text = "https://\(text)" }
        guard let parts = URLComponents(string: text), parts.scheme == "https",
              ["youtube.com", "www.youtube.com", "m.youtube.com"].contains(parts.host?.lowercased() ?? ""),
              parts.user == nil, parts.password == nil, parts.port == nil else { throw CurationError.invalidChannelLink }
        let path = parts.path.split(separator: "/").map(String.init)
        let tabs = ["videos", "featured", "shorts", "streams", "playlists", "about"]
        let kind: String
        let value: String
        if let first = path.first, first.hasPrefix("@"), path.count == 1 || (path.count == 2 && tabs.contains(path[1])) {
            kind = "handle"
            value = String(first.dropFirst())
        } else if path.count >= 2, ["channel", "user", "c"].contains(path[0]),
                  path.count == 2 || (path.count == 3 && tabs.contains(path[2])) {
            kind = path[0]
            value = path[1]
        } else { throw CurationError.invalidChannelLink }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
        guard !value.isEmpty, value.count <= 100, value.unicodeScalars.allSatisfy(allowed.contains) else {
            throw CurationError.invalidChannelLink
        }
        if kind == "channel" {
            guard value.range(of: #"^UC[A-Za-z0-9_-]{22}$"#, options: .regularExpression) != nil else {
                throw CurationError.invalidChannelLink
            }
        }
        var canonical = URLComponents()
        canonical.scheme = "https"
        canonical.host = "www.youtube.com"
        canonical.path = kind == "handle" ? "/@\(value.lowercased())" : "/\(kind)/\(value)"
        guard let url = canonical.url else { throw CurationError.invalidChannelLink }
        self.url = url
        id = kind == "channel" ? value : String(canonical.path.dropFirst())
        youtubeChannelID = kind == "channel" ? value : nil
        username = kind == "user" ? value : nil
    }

    public func channel(name: String, tier: Tier) throws -> Channel {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, name.count <= 100 else { throw CurationError.invalidChannelName }
        return Channel(id: id, name: name, tier: tier, url: url, youtubeChannelID: youtubeChannelID, username: username)
    }
}
