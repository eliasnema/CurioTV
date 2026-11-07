import Foundation
import Testing
@testable import CurioCore

@Suite("Local library")
struct LibraryTests {
    @Test func savesAndRemovesByVideoIdentity() throws {
        let video = try #require(Catalog.load().channels.first?.featuredVideo)
        var library = LibrarySnapshot()
        library.toggleSaved(video)
        #expect(library.savedVideos == [video])
        let renamed = Video(id: video.id, title: "Updated title", channelID: video.channelID, channelName: video.channelName)
        library.toggleSaved(renamed)
        #expect(library.savedVideos.isEmpty)
        library.toggleFavorite(video.channelID)
        #expect(library.favoriteChannelIDs.contains(video.channelID))
        library.toggleFavorite(video.channelID)
        #expect(library.favoriteChannelIDs.isEmpty)
    }

    @Test func openingsAreBoundedUniqueAndOrdered() throws {
        let videos = Array(try Catalog.load().channels.compactMap(\.featuredVideo).prefix(45))
        var library = LibrarySnapshot()
        for video in videos { library.recordOpening(video) }
        #expect(library.openings.count == 40)
        #expect(library.openings.first?.video == videos.last)
        library.recordOpening(videos[10], at: Date(timeIntervalSince1970: 0))
        #expect(library.openings.count == 40)
        #expect(library.openings.first?.video == videos[10])
        #expect(Set(library.openings.map(\.id)).count == 40)
        library.clearOpenings()
        #expect(library.openings.isEmpty)
    }

    @Test func persistenceRoundTripAndCorruption() throws {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appending(path: "library.json")
        #expect(try LibraryPersistence.load(from: url) == LibrarySnapshot())
        let video = try #require(Catalog.load().channels.first?.featuredVideo)
        var library = LibrarySnapshot()
        library.toggleSaved(video)
        library.toggleFavorite(video.channelID)
        library.recordOpening(video)
        try LibraryPersistence.save(library, to: url)
        #expect(try LibraryPersistence.load(from: url) == library)
        try Data("corrupt library".utf8).write(to: url)
        #expect(throws: (any Error).self) { try LibraryPersistence.load(from: url) }
        #expect(try String(contentsOf: url, encoding: .utf8) == "corrupt library")
    }
}
