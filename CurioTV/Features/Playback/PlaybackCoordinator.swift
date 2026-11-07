import CurioCore
import Foundation
import Observation
import UIKit

@MainActor @Observable
final class PlaybackCoordinator {
    var failure: PlaybackFailure?
    private(set) var isOpening = false

    func openVideo(_ video: Video, model: AppModel) async {
        guard !isOpening else { return }
        isOpening = true
        defer { isOpening = false }
        if await open(appURL: video.appURL, universalURL: video.watchURL) {
            model.recordOpening(video)
        } else {
            failure = PlaybackFailure(url: video.watchURL, title: video.title)
        }
    }

    func openChannel(_ channel: Channel) async {
        guard !isOpening else { return }
        isOpening = true
        defer { isOpening = false }
        if !(await open(appURL: YouTubeLink.appURL(for: channel.url), universalURL: channel.url)) {
            failure = PlaybackFailure(url: channel.url, title: channel.name)
        }
    }

    func openYouTube() async {
        if !(await open(appURL: URL(string: "youtube://www.youtube.com"), universalURL: URL(string: "https://www.youtube.com"))) {
            failure = PlaybackFailure(url: URL(string: "https://www.youtube.com"), title: "YouTube")
        }
    }

    private func open(appURL: URL?, universalURL: URL?) async -> Bool {
        if let appURL, await UIApplication.shared.open(appURL) { return true }
        if let universalURL {
            return await UIApplication.shared.open(universalURL, options: [.universalLinksOnly: true])
        }
        return false
    }
}
