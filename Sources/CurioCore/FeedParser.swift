import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public enum FeedParser {
    public static func parse(_ data: Data, channel: Channel) throws -> [Video] {
        let delegate = AtomDelegate(channel: channel)
        let parser = XMLParser(data: data)
        parser.shouldResolveExternalEntities = false
        parser.delegate = delegate
        guard parser.parse(), delegate.isFeed else { throw FeedError.invalidFeed }
        return delegate.videos
    }
}

private final class AtomDelegate: NSObject, XMLParserDelegate {
    let channel: Channel
    var videos: [Video] = []
    var isFeed = false
    private var insideEntry = false
    private var path: [String] = []
    private var text = ""
    private var videoID = ""
    private var title = ""
    private var published = ""
    private var isShort = false
    private var seen: Set<String> = []

    init(channel: Channel) { self.channel = channel }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes: [String: String]) {
        path.append(elementName)
        text = ""
        if path.count == 1, elementName == "feed" { isFeed = true }
        if elementName == "entry" {
            insideEntry = true
            videoID = ""; title = ""; published = ""; isShort = false
        }
        if insideEntry, elementName == "link", attributes["rel"] == "alternate" {
            isShort = attributes["href"]?.contains("/shorts/") == true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) { text += string }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        defer { _ = path.popLast(); text = "" }
        guard insideEntry else { return }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if elementName == "yt:videoId" { videoID = value }
        if elementName == "title", path.suffix(2).elementsEqual(["entry", "title"]) { title = value }
        if elementName == "published" { published = value }
        if elementName == "entry" {
            insideEntry = false
            guard YouTubeLink.isValidVideoID(videoID), !title.isEmpty, seen.insert(videoID).inserted else { return }
            let date = ISO8601DateFormatter().date(from: published)
                ?? ISO8601DateFormatter.fractional.date(from: published)
            videos.append(Video(id: videoID, title: title, channelID: channel.id,
                                channelName: channel.name, publishedAt: date, isShort: isShort))
        }
    }
}

private extension ISO8601DateFormatter {
    static var fractional: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
