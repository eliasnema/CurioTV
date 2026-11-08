import CurioCore
import Foundation
import Observation

@MainActor @Observable
final class AppModel {
    let catalogChannels: [Channel]
    let feedClient = FeedClient()
    let feedDiscovery = ChannelFeedDiscovery()
    private(set) var library = LibrarySnapshot()
    private(set) var curation = CurationSnapshot()
    private(set) var catalogError: String?
    var storageError: String?
    var hideShorts = true {
        didSet { UserDefaults.standard.set(hideShorts, forKey: "hideShorts") }
    }

    private let storageKey = "curioLibrary.v1"
    private let curationKey = "curioCuration.v1"
    private var canSaveLibrary = true
    private var canSaveCuration = true

    var activeCollection: ChannelCollection? { collection(curation.selectedCollectionID) }
    var collectionName: String { activeCollection?.name ?? "Tristan's collection" }
    var suggestedCollectionName: String {
        let names = Set(curation.collections.map { $0.name.lowercased() })
        for candidate in ["My picks", "Family picks"] where !names.contains(candidate.lowercased()) { return candidate }
        var number = 3
        while names.contains("collection \(number)") { number += 1 }
        return "Collection \(number)"
    }
    var channels: [Channel] { activeCollection?.channels ?? catalogChannels }
    var allChannels: [Channel] {
        var seen: Set<String> = []
        return (channels + catalogChannels + curation.collections.flatMap(\.channels)).filter { seen.insert($0.id).inserted }
    }

    func collection(_ id: UUID?) -> ChannelCollection? { curation.collections.first { $0.id == id } }

    init() {
        do { catalogChannels = try Catalog.load().channels }
        catch {
            catalogChannels = []
            catalogError = "The channel collection could not be loaded. Reinstall CurioTV to restore it."
        }
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do { library = try JSONDecoder().decode(LibrarySnapshot.self, from: data) }
            catch {
                library = LibrarySnapshot()
                canSaveLibrary = false
                storageError = "Your saved library could not be read. The original data has been kept. Reset the local library in Settings to start again."
            }
        } else { library = LibrarySnapshot() }
        if let data = UserDefaults.standard.data(forKey: curationKey) {
            do { curation = try JSONDecoder().decode(CurationSnapshot.self, from: data) }
            catch {
                canSaveCuration = false
                storageError = CurationError.storageLocked.localizedDescription
            }
        }
        if UserDefaults.standard.object(forKey: "hideShorts") != nil {
            hideShorts = UserDefaults.standard.bool(forKey: "hideShorts")
        }
    }

    func isSaved(_ video: Video) -> Bool { library.savedVideos.contains { $0.id == video.id } }
    func isFavorite(_ channel: Channel) -> Bool { library.favoriteChannelIDs.contains(channel.id) }
    func channel(for video: Video) -> Channel? { allChannels.first { $0.id == video.channelID } }

    @discardableResult
    func createCollection(name: String, channels: [Channel] = []) throws -> UUID {
        var updated = curation
        let id = try updated.create(name: name, channels: channels)
        try updated.select(id)
        try saveCuration(updated)
        return id
    }

    func duplicateCollection(_ id: UUID, name: String) throws {
        var updated = curation
        let copy = try updated.duplicate(id, name: name)
        try updated.select(copy)
        try saveCuration(updated)
    }

    func renameCollection(_ id: UUID, name: String) throws { try updateCuration { try $0.rename(id, to: name) } }
    func deleteCollection(_ id: UUID) throws { try updateCuration { $0.delete(id) } }
    func selectCollection(_ id: UUID?) throws { try updateCuration { try $0.select(id) } }
    func editCollection(_ id: UUID, _ change: (inout ChannelCollection) throws -> Void) throws {
        try updateCuration { try $0.update(id, change) }
    }

    func toggleSaved(_ video: Video) { updateLibrary { $0.toggleSaved(video) } }
    func toggleFavorite(_ channel: Channel) { updateLibrary { $0.toggleFavorite(channel.id) } }
    func recordOpening(_ video: Video) { updateLibrary { $0.recordOpening(video) } }
    func clearOpenings() { updateLibrary { $0.clearOpenings() } }

    func resetLibrary() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: curationKey)
        canSaveLibrary = true
        library = LibrarySnapshot()
        curation = CurationSnapshot()
        canSaveCuration = true
        storageError = nil
    }

    private func updateLibrary(_ change: (inout LibrarySnapshot) -> Void) {
        guard canSaveLibrary else {
            storageError = "Reset the unreadable library in Settings before saving changes."
            return
        }
        var updated = library
        change(&updated)
        do {
            let data = try JSONEncoder().encode(updated)
            guard data.count + (UserDefaults.standard.data(forKey: curationKey)?.count ?? 0) < 400_000 else {
                storageError = CurationError.storageFull.localizedDescription
                return
            }
            UserDefaults.standard.set(data, forKey: storageKey)
            library = updated
        } catch { storageError = "This change could not be saved. Please try again." }
    }

    private func updateCuration(_ change: (inout CurationSnapshot) throws -> Void) throws {
        var updated = curation
        try change(&updated)
        try saveCuration(updated)
    }

    private func saveCuration(_ updated: CurationSnapshot) throws {
        guard canSaveCuration else { throw CurationError.storageLocked }
        let data = try JSONEncoder().encode(updated)
        guard data.count + (UserDefaults.standard.data(forKey: storageKey)?.count ?? 0) < 400_000 else {
            throw CurationError.storageFull
        }
        UserDefaults.standard.set(data, forKey: curationKey)
        curation = updated
    }
}
