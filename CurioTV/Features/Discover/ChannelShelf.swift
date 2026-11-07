import CurioCore
import SwiftUI

struct ChannelShelf: View {
    let tier: Tier
    let channels: [Channel]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .firstTextBaseline, spacing: 18) {
                Text(tier.rawValue).font(.title2.weight(.bold)).foregroundStyle(Palette.tier(tier))
                Text(tier.title).font(.title3.weight(.semibold))
                Text("\(channels.count) CHANNELS").font(.caption2).tracking(2).foregroundStyle(Palette.secondary)
            }
            .padding(.horizontal, 80)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 28) {
                    ForEach(channels) { channel in ChannelCard(channel: channel) }
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 14)
            }
            .scrollIndicators(.hidden)
        }
        .focusSection()
    }
}
