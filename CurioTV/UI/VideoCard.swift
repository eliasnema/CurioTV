import CurioCore
import SwiftUI

struct VideoCard: View {
    let video: Video
    var identifierPrefix = "video"

    var body: some View {
        NavigationLink(value: video) {
            VStack(alignment: .leading, spacing: 0) {
                ThumbnailView(url: video.thumbnailURL, title: video.channelName)
                    .frame(width: 350, height: 197)
                    .clipped()
                VStack(alignment: .leading, spacing: 9) {
                    Text(video.title).font(.headline).lineLimit(2, reservesSpace: true)
                    Text(video.channelName).font(.caption).foregroundStyle(Palette.secondary).lineLimit(1)
                }
                .padding(20)
            }
            .frame(width: 350)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(FocusCardStyle())
        .accessibilityIdentifier("\(identifierPrefix).\(video.id)")
        .accessibilityLabel("\(video.title), by \(video.channelName)")
        .accessibilityHint("Show video details and playback options")
    }
}
