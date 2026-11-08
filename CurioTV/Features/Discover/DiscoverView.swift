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
                CollectionSwitcher().padding(.horizontal, 80)
                if let error = model.catalogError {
                    ContentUnavailableView("Collection unavailable", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    if let channel = featuredChannel { HeroView(channel: channel).padding(.horizontal, 80) }
                    if model.channels.isEmpty {
                        ContentUnavailableView("Your collection starts here", systemImage: "square.stack",
                            description: Text("Add channels in Collections, or switch back to Tristan's collection above."))
                    }
                    ForEach(Tier.allCases) { tier in
                        let channels = model.channels.filter { $0.tier == tier }
                        if !channels.isEmpty { ChannelShelf(tier: tier, channels: channels) }
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
            Text(model.activeCollection == nil ? "CURATED BY TRISTAN HUME  /  NOVEMBER 2026" : "YOUR COLLECTION  /  \(model.collectionName.uppercased())")
                .font(.caption2).tracking(2).foregroundStyle(Palette.secondary)
            Spacer()
            Text("\(model.channels.count) channels. One curious place.")
                .font(.caption).foregroundStyle(Palette.secondary)
        }
    }
}
