import Foundation
import Testing
@testable import CurioCore

@Suite("YouTube Atom feeds")
struct FeedTests {
    @Test func parsesTitlesDatesShortsAndDeduplicates() throws {
        let url = try #require(Bundle.module.url(forResource: "uploads", withExtension: "xml"))
        let channel = try #require(Catalog.load().channels.first)
        let videos = try FeedParser.parse(Data(contentsOf: url), channel: channel)
        #expect(videos.count == 2)
        #expect(videos[0].title == "Science & craft: <inside> a machine")
        #expect(videos[0].channelName == "Applied Science")
        #expect(videos[0].isShort == false)
        #expect(videos[0].publishedAt != nil)
        #expect(videos[1].isShort)
        #expect(videos[1].publishedAt != nil)
    }

    @Test func rejectsInvalidXMLAndNonFeeds() throws {
        let channel = try #require(Catalog.load().channels.first)
        for invalid in ["<feed><entry>", "<html><title>Blocked</title></html>", "not XML"] {
            #expect(throws: (any Error).self) { try FeedParser.parse(Data(invalid.utf8), channel: channel) }
        }
    }

    @Test func emptyChannelRemainsEmpty() throws {
        let channel = try #require(Catalog.load().channels.first)
        #expect(try FeedParser.parse(Data("<feed/>".utf8), channel: channel).isEmpty)
    }
}
