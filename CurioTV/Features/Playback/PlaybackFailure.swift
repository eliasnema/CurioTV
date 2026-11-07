import Foundation

struct PlaybackFailure: Identifiable {
    let id = UUID()
    let url: URL?
    let title: String
}
