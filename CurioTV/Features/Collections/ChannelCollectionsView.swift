import CurioCore
import SwiftUI

struct ChannelCollectionsView: View {
    @Environment(AppModel.self) private var model
    let channel: Channel
    @State private var message: String?
    @State private var editor: CollectionNameView.Mode?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Curate \(channel.name)").font(.title.weight(.bold))
                Text("Choose a tier in any collection. If the channel is already there, it moves to your chosen tier. Each collection keeps its own ranking.")
                    .foregroundStyle(Palette.secondary)
                Button("New collection", systemImage: "plus") {
                    editor = .create(model.suggestedCollectionName)
                }
                if let message { Text(message).foregroundStyle(Palette.accent).fixedSize(horizontal: false, vertical: true) }
                ForEach(model.curation.collections) { collection in
                    VStack(alignment: .leading, spacing: 20) {
                        Text(collection.name).font(.title3.weight(.semibold))
                        HStack(spacing: 18) {
                            ForEach(Tier.allCases) { tier in
                                Button("\(tier.rawValue) · \(collection.count(in: tier))\(collection.limit(for: tier).map { "/\($0)" } ?? "")") {
                                    do {
                                        try model.editCollection(collection.id) { try $0.add([channel], tier: tier) }
                                        message = "Saved in \(collection.name), tier \(tier.rawValue)."
                                    } catch { message = error.localizedDescription }
                                }
                                .buttonStyle(ActionButtonStyle(prominent: collection.channels.contains { $0.id == channel.id && $0.tier == tier }))
                                .accessibilityLabel("\(collection.name), tier \(tier.rawValue)")
                            }
                        }
                    }
                    .focusSection()
                }
            }
            .padding(.horizontal, 90).padding(.vertical, 60)
        }
        .background(Palette.background)
        .sheet(item: $editor) { CollectionNameView(mode: $0) }
    }
}
