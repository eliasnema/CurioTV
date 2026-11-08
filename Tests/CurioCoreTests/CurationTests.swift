import Foundation
import Testing
@testable import CurioCore

@Suite("Personal channel curation")
struct CurationTests {
    @Test func originalCanBeCopiedAndPersonalRankingsStayIndependent() throws {
        let original = try Catalog.load().channels
        var curation = CurationSnapshot()
        let first = try curation.create(name: "My picks", channels: original)
        let second = try curation.create(name: "Family picks", channels: [original[0]])
        try curation.update(first) { try $0.move([original[0].id], to: .d) }
        #expect(curation.collections[0].channels[0].tier == .d)
        #expect(curation.collections[1].channels[0].tier == original[0].tier)
        #expect(try Catalog.load().channels == original)
        #expect(first != second)
        #expect(throws: CurationError.duplicateName) { try curation.create(name: " MY PICKS ") }
        #expect(throws: CurationError.duplicateName) { try curation.rename(second, to: "my picks") }
    }

    @Test func tierLimitsRejectWholeChangesAndNeverDiscardChannels() throws {
        let channels = Array(try Catalog.load().channels.prefix(4))
        var collection = try ChannelCollection(name: "Small shortlist")
        try collection.setLimit(1, for: .s)
        try collection.add([channels[0]], tier: .s)
        let before = collection
        #expect(throws: CurationError.tierFull(.s, limit: 1, requested: 3)) {
            try collection.add(Array(channels[1...2]), tier: .s)
        }
        #expect(collection == before)
        try collection.add([channels[0]], tier: .s)
        #expect(collection.channels.count == 1)
        try collection.add(Array(channels[1...2]), tier: .b)
        let beforeMove = collection
        #expect(throws: CurationError.tierFull(.s, limit: 1, requested: 3)) {
            try collection.move(Set(channels[1...2].map(\.id)), to: .s)
        }
        #expect(collection == beforeMove)
        #expect(throws: CurationError.tierFull(.b, limit: 1, requested: 2)) { try collection.setLimit(1, for: .b) }
        #expect(collection.limit(for: .b) == nil)
        try collection.setLimit(nil, for: .s)
        try collection.move(Set(channels[1...2].map(\.id)), to: .s)
        #expect(collection.count(in: .s) == 3)
        #expect(throws: CurationError.invalidLimit) { try collection.setLimit(0, for: .a) }
    }

    @Test func bulkAddsKeepOrReplaceTiersAndDeletingSelectedCollectionFallsBack() throws {
        let channels = Array(try Catalog.load().channels.prefix(6))
        var curation = CurationSnapshot()
        let id = try curation.create(name: "Weekend")
        try curation.update(id) { try $0.add(channels) }
        #expect(curation.collections[0].channels.map(\.tier) == channels.map(\.tier))
        try curation.update(id) { try $0.add(channels, tier: .b) }
        #expect(curation.collections[0].channels.count == 6)
        #expect(curation.collections[0].count(in: .b) == 6)
        try curation.update(id) { $0.remove([channels[0].id, channels[1].id]) }
        #expect(curation.collections[0].channels.count == 4)
        try curation.select(id)
        curation.delete(id)
        #expect(curation.collections.isEmpty)
        #expect(curation.selectedCollectionID == nil)
        #expect(throws: CurationError.collectionMissing) { try curation.select(id) }
    }

    @Test func curationRoundTripDoesNotChangeTheLegacyLibraryFormat() throws {
        let legacy = Data(#"{"savedVideos":[],"favoriteChannelIDs":["example"],"openings":[]}"#.utf8)
        let library = try JSONDecoder().decode(LibrarySnapshot.self, from: legacy)
        #expect(library.favoriteChannelIDs == ["example"])
        var curation = CurationSnapshot()
        let channel = try ChannelAddress("@example").channel(name: "Example", tier: .a)
        let id = try curation.create(name: "Personal", channels: [channel])
        try curation.update(id) { try $0.setLimit(5, for: .a) }
        try curation.select(id)
        let data = try JSONEncoder().encode(curation)
        #expect(try JSONDecoder().decode(CurationSnapshot.self, from: data) == curation)
        var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["selectedCollectionID"] = UUID().uuidString
        let corrupt = try JSONSerialization.data(withJSONObject: object)
        #expect(throws: (any Error).self) { try JSONDecoder().decode(CurationSnapshot.self, from: corrupt) }
        #expect(try JSONDecoder().decode(LibrarySnapshot.self, from: legacy) == library)
    }

    @Test func channelLinksAreCanonicalizedWithoutAcceptingVideoOrForeignURLs() throws {
        let id = "UCivA7_KLKWo43tFcCkFvydw"
        #expect(try ChannelAddress(id).youtubeChannelID == id)
        #expect(try ChannelAddress("https://youtube.com/channel/\(id)/videos?si=tracking").url.absoluteString == "https://www.youtube.com/channel/\(id)")
        #expect(try ChannelAddress("@Example").id == "@example")
        #expect(try ChannelAddress("https://www.youtube.com/@EXAMPLE/shorts").id == "@example")
        #expect(try ChannelAddress("https://m.youtube.com/user/example").username == "example")
        for bad in ["https://example.com/@test", "https://www.youtube.com/watch?v=RpslsMqPFWA", "https://youtu.be/RpslsMqPFWA", "http://youtube.com/@test", "https://youtube.com:443/@test", "https://user@youtube.com/@test", "https://youtube.com/@test/../../watch", "https://youtube.com/channel/invalid", "https://youtube.com/@bad%2Fname"] {
            #expect(throws: CurationError.invalidChannelLink) { try ChannelAddress(bad) }
        }
    }

    @Test func advertisedFeedsRequireAYouTubeRSSLinkAndCopiesKeepLimits() throws {
        let id = "UC6107grRI4m0o2-emgoDnAA"
        let valid = "<link rel='alternate' type='application/rss+xml' href='https://www.youtube.com/feeds/videos.xml?channel_id=\(id)'>"
        #expect(ChannelFeedDiscovery.advertisedChannelID(in: valid) == id)
        #expect(ChannelFeedDiscovery.advertisedChannelID(in: "<a href='https://www.youtube.com/feeds/videos.xml?channel_id=\(id)'>") == nil)
        #expect(ChannelFeedDiscovery.advertisedChannelID(in: valid.replacingOccurrences(of: "www.youtube.com", with: "example.com")) == nil)
        #expect(ChannelFeedDiscovery.advertisedChannelID(in: valid.replacingOccurrences(of: id, with: "invalid")) == nil)
        var curation = CurationSnapshot()
        let original = try curation.create(name: "Small")
        try curation.update(original) { try $0.setLimit(3, for: .s) }
        let copy = try curation.duplicate(original, name: "Small copy")
        try curation.update(copy) { try $0.setLimit(5, for: .s) }
        #expect(curation.collections[0].limit(for: .s) == 3)
        #expect(curation.collections[1].limit(for: .s) == 5)
    }
}
