import CurioCore
import Foundation
import Observation

@MainActor @Observable
final class AppModel {
    let channels: [Channel]
    let feedClient = FeedClient()
    private(set) var library = LibrarySnapshot()
    private(set) var catalogError: String?
    var storageError: String?
    var hideShorts = true {
        didSet { UserDefaults.standard.set(hideShorts, forKey: "hideShorts") }
    }

    private let storageKey = "curioLibrary.v1"
    private var canSaveLibrary = true

    init() {
        do { channels = try Catalog.load().channels }
        catch {
            channels = []
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
        if UserDefaults.standard.object(forKey: "hideShorts") != nil {
            hideShorts = UserDefaults.standard.bool(forKey: "hideShorts")
        }
    }

    func isSaved(_ video: Video) -> Bool { library.savedVideos.contains { $0.id == video.id } }
    func isFavorite(_ channel: Channel) -> Bool { library.favoriteChannelIDs.contains(channel.id) }
    func channel(for video: Video) -> Channel? { channels.first { $0.id == video.channelID } }

    func toggleSaved(_ video: Video) { updateLibrary { $0.toggleSaved(video) } }
    func toggleFavorite(_ channel: Channel) { updateLibrary { $0.toggleFavorite(channel.id) } }
    func recordOpening(_ video: Video) { updateLibrary { $0.recordOpening(video) } }
    func clearOpenings() { updateLibrary { $0.clearOpenings() } }

    func resetLibrary() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        canSaveLibrary = true
        library = LibrarySnapshot()
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
            guard data.count < 400_000 else {
                storageError = "Your local library is full. Remove a few saved videos before adding more."
                return
            }
            UserDefaults.standard.set(data, forKey: storageKey)
            library = updated
        } catch { storageError = "This change could not be saved. Please try again." }
    }
}
