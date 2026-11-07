import CurioCore
import SwiftUI

struct DiscoverView: View {
    @Environment(AppModel.self) private var model

    private var featuredChannel: Channel? {
        model.channels.first { $0.name == "Stuff Made Here" } ?? model.channels.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                BrandHeader().padding(.horizontal, 80)
                if let error = model.catalogError {
                    ContentUnavailableView("Collection unavailable", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    if let channel = featuredChannel { HeroView(channel: channel).padding(.horizontal, 80) }
                    ForEach(Tier.allCases) { tier in
                        ChannelShelf(tier: tier, channels: model.channels.filter { $0.tier == tier })
                    }
                    sourceCredit.padding(.horizontal, 80)
                }
            }
            .padding(.top, 42)
            .padding(.bottom, 70)
        }
        .background(Palette.background)
        .curioDestinations()
    }

    private var sourceCredit: some View {
        HStack {
            Text("CURATED BY TRISTAN HUME  /  NOVEMBER 2026")
                .font(.caption2).tracking(2).foregroundStyle(Palette.secondary)
            Spacer()
            Text("\(model.channels.count) channels. One curious place.")
                .font(.caption).foregroundStyle(Palette.secondary)
        }
    }
}
