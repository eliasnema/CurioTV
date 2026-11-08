import CurioCore
import SwiftUI

struct ChannelsView: View {
    @Environment(AppModel.self) private var model
    @State private var query = ""
    @State private var selectedTier: Tier?
    @State private var favoritesOnly = false

    private var filteredChannels: [Channel] {
        model.channels.filter {
            (selectedTier == nil || $0.tier == selectedTier) && $0.matches(query)
                && (!favoritesOnly || model.isFavorite($0))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Find your next fascination.").font(.title.weight(.bold))
                        Text("\(filteredChannels.count) of \(model.channels.count) channels · \(model.activeCollection == nil ? "Selection by Tristan Hume" : model.collectionName)")
                            .font(.caption).foregroundStyle(Palette.secondary)
                    }
                    Spacer()
                }
                CollectionSwitcher()
                HStack(spacing: 24) {
                    TextField("Search channels and article picks", text: $query)
                        .frame(maxWidth: 800)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Search channels and article picks")
                    Button(favoritesOnly ? "Showing favorites" : "All channels", systemImage: favoritesOnly ? "heart.fill" : "heart") {
                        favoritesOnly.toggle()
                    }
                }
                HStack(spacing: 20) {
                    tierButton(nil)
                    ForEach(Tier.allCases) { tier in tierButton(tier) }
                }
                .focusSection()
                if filteredChannels.isEmpty {
                    ContentUnavailableView("No channels found", systemImage: "magnifyingglass",
                                           description: Text("Try a different search or clear your filters."))
                    Button("Clear filters") { query = ""; selectedTier = nil; favoritesOnly = false }
                    if model.channels.isEmpty { NavigationLink("Add channels to this collection", destination: CollectionsView()) }
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350), spacing: 36)], alignment: .leading, spacing: 36) {
                        ForEach(filteredChannels) { channel in ChannelCard(channel: channel) }
                    }
                    .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 50)
        }
        .background(Palette.background)
        .curioDestinations()
    }

    private func tierButton(_ tier: Tier?) -> some View {
        Button {
            selectedTier = tier
        } label: {
            HStack(spacing: 9) {
                if selectedTier == tier { Image(systemName: "checkmark").accessibilityHidden(true) }
                Text(tier.map { "\($0.rawValue) tier" } ?? "All tiers")
            }
            .font(.caption.weight(.semibold))
        }
        .buttonStyle(ActionButtonStyle(prominent: selectedTier == tier))
        .accessibilityLabel(tier.map { "Tier \($0.rawValue)" } ?? "All tiers")
        .accessibilityAddTraits(selectedTier == tier ? [.isSelected] : [])
    }
}
