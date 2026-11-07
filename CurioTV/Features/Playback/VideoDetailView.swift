import CurioCore
import SwiftUI

struct VideoDetailView: View {
    @Environment(AppModel.self) private var model
    let video: Video
    @State private var playback = PlaybackCoordinator()

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 60) {
                ThumbnailView(url: video.thumbnailURL, title: video.channelName)
                    .frame(width: 790, height: 445).clipped()
                    .clipShape(.rect(cornerRadius: 22))
                VStack(alignment: .leading, spacing: 30) {
                    Text(video.channelName.uppercased())
                        .font(.caption.weight(.semibold)).tracking(3).foregroundStyle(Palette.accent)
                    Text(video.title).font(.title2.weight(.bold)).fixedSize(horizontal: false, vertical: true)
                    if let date = video.publishedAt {
                        Text(date, format: .dateTime.day().month(.wide).year())
                            .font(.caption).foregroundStyle(Palette.secondary)
                    } else if model.channel(for: video)?.featuredVideo?.id == video.id {
                        Text("From Tristan Hume's November 2026 collection")
                            .font(.caption).foregroundStyle(Palette.secondary)
                    } else {
                        Text("Recent channel upload").font(.caption).foregroundStyle(Palette.secondary)
                    }
                    Button("Watch in YouTube", systemImage: "play.fill") {
                        Task { await playback.openVideo(video, model: model) }
                    }
                    .buttonStyle(ActionButtonStyle(prominent: true))
                    .disabled(playback.isOpening)
                    .accessibilityIdentifier("video.watch")
                    .accessibilityHint("Leaves CurioTV and opens the official YouTube app")
                    Button(model.isSaved(video) ? "Saved to My Library" : "Save for later",
                           systemImage: model.isSaved(video) ? "bookmark.fill" : "bookmark") {
                        model.toggleSaved(video)
                    }
                    .accessibilityIdentifier("video.save")
                    if let channel = model.channel(for: video) {
                        NavigationLink("More from \(channel.name)", value: channel)
                    }
                    Text("Playback opens in YouTube. Your selected YouTube account, history settings, and Premium membership apply there.")
                        .font(.caption).foregroundStyle(Palette.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .focusSection()
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 100)
        }
        .background(Palette.background)
        .sheet(item: $playback.failure) { failure in PlaybackHelpView(failure: failure) }
    }
}
