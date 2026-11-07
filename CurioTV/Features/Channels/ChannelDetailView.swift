import CurioCore
import SwiftUI

struct ChannelDetailView: View {
    @Environment(AppModel.self) private var model
    let channel: Channel
    @State private var uploads: [Video] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var playback = PlaybackCoordinator()

    private var visibleUploads: [Video] { uploads.filter { !model.hideShorts || !$0.isShort } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                header
                if let video = channel.featuredVideo {
                    HStack(alignment: .top, spacing: 40) {
                        VideoCard(video: video)
                        VStack(alignment: .leading, spacing: 18) {
                            Text("THE ARTICLE PICK").font(.caption.weight(.bold)).tracking(3).foregroundStyle(Palette.accent)
                            Text(video.title).font(.title3.weight(.semibold))
                            Text("A starting point from the November 2026 collection.")
                                .font(.body).foregroundStyle(Palette.secondary)
                            NavigationLink("Video details", value: video)
                        }
                        .padding(.top, 16)
                    }
                }
                HStack {
                    Text("Recent uploads").font(.title2.weight(.semibold))
                    Spacer()
                    if isLoading { ProgressView().accessibilityLabel("Loading recent uploads") }
                    Button("Refresh", systemImage: "arrow.clockwise") { Task { await load(forceRefresh: true) } }
                        .disabled(isLoading)
                }
                Text(model.hideShorts ? "Shorts are hidden. Change this in Settings." : "Includes Shorts where YouTube identifies them.")
                    .font(.caption).foregroundStyle(Palette.secondary)
                if let error {
                    Text(error).font(.body).foregroundStyle(Palette.secondary)
                    Button("Try again") { Task { await load(forceRefresh: true) } }
                } else if !isLoading && visibleUploads.isEmpty {
                    Text("No recent uploads to show. Explore the channel on YouTube for its full archive.")
                        .font(.body).foregroundStyle(Palette.secondary)
                }
                ChannelUploadsGrid(videos: visibleUploads).padding(.vertical, 12)
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 60)
        }
        .background(Palette.background)
        .task { await load() }
        .sheet(item: $playback.failure) { failure in PlaybackHelpView(failure: failure) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 24) {
            TierBadge(tier: channel.tier)
            Text(channel.name).font(.largeTitle.weight(.bold))
            HStack(spacing: 24) {
                Button(model.isFavorite(channel) ? "Favorited" : "Favorite channel",
                       systemImage: model.isFavorite(channel) ? "heart.fill" : "heart") {
                    model.toggleFavorite(channel)
                }
                Button("Open channel in YouTube", systemImage: "arrow.up.right") {
                    Task { await playback.openChannel(channel) }
                }
            }
        }
        .focusSection()
    }

    private func load(forceRefresh: Bool = false) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do { uploads = try await model.feedClient.videos(for: channel, forceRefresh: forceRefresh) }
        catch is CancellationError { }
        catch { self.error = error.localizedDescription }
    }
}
