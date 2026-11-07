import Foundation

public enum YouTubeLink {
    public static func isValidVideoID(_ value: String) -> Bool {
        value.range(of: #"^[A-Za-z0-9_-]{11}$"#, options: .regularExpression) != nil
    }

    public static func video(id: String, scheme: String) -> URL? {
        guard isValidVideoID(id), ["https", "youtube"].contains(scheme) else { return nil }
        var components = URLComponents()
        components.scheme = scheme
        components.host = "www.youtube.com"
        components.path = "/watch"
        components.queryItems = [URLQueryItem(name: "v", value: id)]
        return components.url
    }

    public static func appURL(for channelURL: URL) -> URL? {
        guard channelURL.host == "www.youtube.com", channelURL.scheme == "https",
              channelURL.path.hasPrefix("/channel/") || channelURL.path.hasPrefix("/user/")
                || channelURL.path.hasPrefix("/@") || channelURL.path.hasPrefix("/c/") else { return nil }
        var components = URLComponents(url: channelURL, resolvingAgainstBaseURL: false)
        components?.scheme = "youtube"
        return components?.url
    }
}
