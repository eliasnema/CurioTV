import CurioCore
import SwiftUI

struct LibraryView: View {
    @Environment(AppModel.self) private var model

    private var favorites: [Channel] { model.allChannels.filter { model.isFavorite($0) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your corner of curiosity.").font(.title.weight(.bold))
                    Text("Saved on this Apple TV. Your YouTube history stays in YouTube.")
                        .font(.body).foregroundStyle(Palette.secondary)
                }
                if model.library.savedVideos.isEmpty && favorites.isEmpty && model.library.openings.isEmpty {
                    ContentUnavailableView("Make yourself at home", systemImage: "bookmark",
                                           description: Text("Save a video or favorite a channel to find it here."))
                }
                if !favorites.isEmpty {
                    Text("Favorite channels").font(.title2.weight(.semibold))
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 36) {
                        ForEach(favorites) { channel in ChannelCard(channel: channel) }
                    }
                }
                if !model.library.savedVideos.isEmpty {
                    Text("Saved for later").font(.title2.weight(.semibold))
                    Text("Your CurioTV list. This does not change YouTube's Watch Later playlist.")
                        .font(.caption).foregroundStyle(Palette.secondary)
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 36) {
                        ForEach(model.library.savedVideos) { video in VideoCard(video: video) }
                    }
                }
                if !model.library.openings.isEmpty {
                    Text("Opened in YouTube").font(.title2.weight(.semibold))
                    Text("Links opened from CurioTV. This does not confirm that a video was played or finished.")
                        .font(.caption).foregroundStyle(Palette.secondary)
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 36) {
                        ForEach(model.library.openings) { opening in VideoCard(video: opening.video) }
                    }
                }
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 60)
        }
        .background(Palette.background)
        .curioDestinations()
    }

    private var columns: [GridItem] { [GridItem(.adaptive(minimum: 350), spacing: 36)] }
}
