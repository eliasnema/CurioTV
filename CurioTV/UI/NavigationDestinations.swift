import CurioCore
import SwiftUI

extension View {
    func curioDestinations() -> some View {
        navigationDestination(for: Channel.self) { channel in
            ChannelDetailView(channel: channel)
        }
        .navigationDestination(for: Video.self) { video in
            VideoDetailView(video: video)
        }
    }
}
