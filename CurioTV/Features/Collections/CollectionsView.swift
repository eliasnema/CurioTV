import CurioCore
import SwiftUI

struct CollectionsView: View {
    @Environment(AppModel.self) private var model
    @State private var editor: CollectionNameView.Mode?
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Curate your channels.").font(.title.weight(.bold))
                Text("Separate collections for different interests or people. Each has its own tiers and optional channel-count limits.")
                    .foregroundStyle(Palette.secondary)
                HStack(spacing: 26) {
                    Button("New collection", systemImage: "plus") {
                        editor = .create(model.suggestedCollectionName)
                    }
                    .buttonStyle(ActionButtonStyle(prominent: true))
                    .accessibilityIdentifier("collections.create")
                    Button("Use Tristan's collection") {
                        do { try model.selectCollection(nil); message = "Tristan's collection is selected in Discover and Channels." }
                        catch { message = error.localizedDescription }
                    }
                }
                if let message { Text(message).foregroundStyle(Palette.accent) }
                Text("Browsing: \(model.collectionName)").font(.headline)
                if model.curation.collections.isEmpty {
                    ContentUnavailableView("Make a collection your own", systemImage: "square.stack.3d.up",
                        description: Text("Start empty or copy Tristan's list. Add individual channels, select a whole group, and move them between tiers."))
                }
                ForEach(model.curation.collections) { collection in
                    NavigationLink {
                        CollectionDetailView(collectionID: collection.id)
                    } label: {
                        HStack(spacing: 24) {
                            Image(systemName: model.curation.selectedCollectionID == collection.id ? "checkmark.circle.fill" : "square.stack")
                            VStack(alignment: .leading, spacing: 8) {
                                Text(collection.name).font(.headline)
                                Text("\(collection.channels.count) channels · \(Tier.allCases.map { "\($0.rawValue): \(collection.count(in: $0))" }.joined(separator: "  "))")
                                    .font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .accessibilityIdentifier("collection.\(collection.id)")
                }
                Text("Collections organize browsing on this Apple TV. They do not restrict access to other collections or to YouTube.")
                    .font(.caption).foregroundStyle(Palette.secondary)
            }
            .padding(.horizontal, 90).padding(.vertical, 60)
        }
        .background(Palette.background)
        .sheet(item: $editor) { CollectionNameView(mode: $0) }
        .curioDestinations()
    }
}
