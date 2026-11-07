import Foundation
import Testing
@testable import CurioCore

@Suite("Imported collection")
struct CatalogTests {
    @Test func completeCatalog() throws {
        let catalog = try Catalog.load()
        #expect(catalog.channels.count == 156)
        #expect(Dictionary(grouping: catalog.channels, by: \.tier).mapValues(\.count) == [.s: 5, .a: 14, .b: 12, .c: 33, .d: 92])
        #expect(catalog.channels.compactMap(\.featuredVideo).count == 136)
        #expect(catalog.sourceURL.absoluteString == "https://thume.ca/2026/11/01/youtube-tier-list-2026/")
        #expect(catalog.channels.first?.name == "Applied Science")
    }

    @Test func feedIdentifiersArePreserved() throws {
        let channels = try Catalog.load().channels
        #expect(channels.filter { $0.youtubeChannelID != nil }.count == 155)
        #expect(channels.allSatisfy { $0.feedURL != nil })
        let legacy = try #require(channels.first { $0.name == "Blender Guru" })
        #expect(legacy.feedURL?.query == "user=AndrewPPrice")
        let applied = try #require(channels.first)
        #expect(applied.feedURL?.query == "channel_id=UCivA7_KLKWo43tFcCkFvydw")
    }

    @Test func searchMatchesNamesTitlesAndMultipleWords() throws {
        let channels = try Catalog.load().channels
        #expect(channels.filter { $0.matches("  applied SCIENCE  ") }.map(\.name) == ["Applied Science"])
        #expect(channels.filter { $0.matches("apple peel") }.map(\.name) == ["Stuff Made Here"])
        #expect(channels.first?.matches("science impossiblematchingterm") == false)
        #expect(channels.allSatisfy { $0.matches("   ") })
    }

    @Test func linksRejectInjectedPathsAndForeignHosts() throws {
        #expect(YouTubeLink.video(id: "NwhVJ7cv9B4", scheme: "youtube")?.absoluteString == "youtube://www.youtube.com/watch?v=NwhVJ7cv9B4")
        for id in ["", "../watch?v=x", "NwhVJ7cv9B4&redirect=evil", "too-short", "éwhVJ7cv9B4"] {
            #expect(YouTubeLink.video(id: id, scheme: "https") == nil)
        }
        #expect(YouTubeLink.video(id: "NwhVJ7cv9B4", scheme: "file") == nil)
        let foreign = try #require(URL(string: "https://example.com/channel/123"))
        #expect(YouTubeLink.appURL(for: foreign) == nil)
        let channel = try #require(Catalog.load().channels.first)
        #expect(YouTubeLink.appURL(for: channel.url)?.scheme == "youtube")
    }
}
