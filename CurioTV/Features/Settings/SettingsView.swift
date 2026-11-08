import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var playback = PlaybackCoordinator()
    @State private var showResetConfirmation = false
    @State private var showClearConfirmation = false

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                Text("A little setup. A lot to discover.").font(.title.weight(.bold))
                accountSection
                VStack(alignment: .leading, spacing: 24) {
                    Text("Your browsing preferences").font(.title2.weight(.semibold))
                    Toggle("Hide YouTube Shorts in recent uploads", isOn: $model.hideShorts)
                        .frame(maxWidth: 1000)
                    Text("Uses the Shorts link supplied by YouTube. Feeds do not include video durations.")
                        .font(.caption).foregroundStyle(Palette.secondary)
                }
                VStack(alignment: .leading, spacing: 24) {
                    Text("On this Apple TV").font(.title2.weight(.semibold))
                    Text("Collections, channel rankings, favorites, saved videos, and opened links are stored locally. CurioTV never requests your Google password or account tokens.")
                        .font(.body).foregroundStyle(Palette.secondary)
                    HStack(spacing: 32) {
                        Button("Clear opened links", role: .destructive) { showClearConfirmation = true }
                            .confirmationDialog("Clear links opened from CurioTV?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
                                Button("Clear opened links", role: .destructive) { model.clearOpenings() }
                            } message: { Text("Your YouTube history will not change.") }
                        Button("Reset local library", role: .destructive) { showResetConfirmation = true }
                            .confirmationDialog("Reset your CurioTV library?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                                Button("Reset library", role: .destructive) { model.resetLibrary() }
                            } message: { Text("This removes your collections, custom channels, rankings, favorites, saved videos, and opened links on this Apple TV. Tristan's bundled collection stays available.") }
                    }
                }
                Divider()
                sourceSection
            }
            .padding(.horizontal, 100)
            .padding(.vertical, 60)
        }
        .background(Palette.background)
        .sheet(item: $playback.failure) { failure in PlaybackHelpView(failure: failure) }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            Label("Your YouTube account", systemImage: "person.crop.circle")
                .font(.title2.weight(.semibold))
            Text("Sign in once, in YouTube.")
                .font(.title3.weight(.semibold)).foregroundStyle(Palette.accent)
            Text("1. Open the official YouTube app.\n2. Sign in and choose your usual account.\n3. Return to CurioTV and choose a video to watch in YouTube.")
                .font(.body).lineSpacing(12)
            Text("YouTube handles playback, watch history, and Premium benefits using the account selected in its app. CurioTV stores only your local library and the links it successfully opens.")
                .font(.body).foregroundStyle(Palette.secondary)
            Button("Open the YouTube app", systemImage: "arrow.up.right") {
                Task { await playback.openYouTube() }
            }
            .buttonStyle(ActionButtonStyle(prominent: true))
            .accessibilityIdentifier("settings.openYouTube")
        }
        .padding(40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: .rect(cornerRadius: 22))
        .focusSection()
    }

    private var sourceSection: some View {
        HStack(alignment: .top, spacing: 70) {
            VStack(alignment: .leading, spacing: 20) {
                Text("A collection by Tristan Hume").font(.title3.weight(.semibold))
                Text("The original \(model.catalogChannels.count) channels and their S–D tiers come from “My YouTube tier list, six years later”, published on 1 November 2026. Your own collections keep separate rankings. Scan to read the original list.")
                    .font(.body).foregroundStyle(Palette.secondary)
                Text("Independent app. Not affiliated with YouTube, Google, or the curator.")
                    .font(.caption).foregroundStyle(Palette.secondary)
                Text("CurioTV 0.5.0").font(.caption2).foregroundStyle(Palette.secondary)
            }
            if let url = URL(string: "https://thume.ca/2026/11/01/youtube-tier-list-2026/") { QRCodeView(url: url) }
        }
    }
}
