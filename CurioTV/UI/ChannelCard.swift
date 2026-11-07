import CurioCore
import SwiftUI

struct ChannelCard: View {
    let channel: Channel

    var body: some View {
        NavigationLink(value: channel) {
            VStack(alignment: .leading, spacing: 0) {
                ThumbnailView(url: channel.featuredVideo?.thumbnailURL, title: channel.name)
                    .frame(width: 350, height: 197)
                    .clipped()
                    .overlay(alignment: .topLeading) { TierBadge(tier: channel.tier).padding(14) }
                VStack(alignment: .leading, spacing: 9) {
                    Text(channel.name).font(.headline).lineLimit(1)
                    Text(channel.featuredVideo?.title ?? "Explore this channel on YouTube")
                        .font(.caption).foregroundStyle(Palette.secondary).lineLimit(2, reservesSpace: true)
                }
                .padding(20)
            }
            .frame(width: 350)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(FocusCardStyle())
        .accessibilityIdentifier("channel.\(channel.id)")
        .accessibilityLabel("\(channel.name), tier \(channel.tier.rawValue)")
        .accessibilityHint("Browse channel videos")
    }
}
