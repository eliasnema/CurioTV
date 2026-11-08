import CurioCore
import SwiftUI

struct CollectionDetailView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let collectionID: UUID
    @State private var editor: CollectionNameView.Mode?
    @State private var selected: Set<String> = []
    @State private var selecting = false
    @State private var moving: Channel?
    @State private var showingMove = false
    @State private var error: String?
    @State private var confirmRemoval = false
    @State private var confirmDeletion = false

    var body: some View {
        ScrollView {
            if let collection = model.collection(collectionID) {
                VStack(alignment: .leading, spacing: 28) {
                    Text(collection.name).font(.title.weight(.bold))
                    Text("\(collection.channels.count) channels · Your own tiers").foregroundStyle(Palette.secondary)
                    HStack(spacing: 24) {
                        Button(model.curation.selectedCollectionID == collectionID ? "Using this collection" : "Use this collection", systemImage: "checkmark.circle") {
                            perform { try model.selectCollection(collectionID) }
                        }
                        NavigationLink("Add channels", destination: AddChannelsView(collectionID: collectionID))
                            .accessibilityIdentifier("collection.addChannels")
                        NavigationLink("Add channel link", destination: AddCustomChannelView(collectionID: collectionID))
                            .accessibilityIdentifier("collection.addLink")
                    }
                    HStack(spacing: 24) {
                        NavigationLink("Tier limits", destination: TierLimitsView(collectionID: collectionID))
                            .accessibilityIdentifier("collection.limits")
                        Button("Rename") { editor = .rename(collection) }
                        Button("Duplicate") { editor = .duplicate(collection) }
                        Button(selecting ? "Done selecting" : "Select channels") { selecting.toggle(); selected = [] }
                            .accessibilityIdentifier("collection.selectChannels")
                    }
                    if selecting {
                        selectionActions(collection)
                    }
                    if let error { Text(error).foregroundStyle(Palette.accent).fixedSize(horizontal: false, vertical: true) }
                    if collection.channels.isEmpty {
                        ContentUnavailableView("Choose your first channels", systemImage: "plus.rectangle.on.rectangle",
                            description: Text("Add from the source collection, copy a group from another collection, or enter a YouTube channel link."))
                    }
                    ForEach(Tier.allCases) { tier in
                        VStack(alignment: .leading, spacing: 18) {
                            Text("\(tier.rawValue) tier · \(collection.count(in: tier))\(collection.limit(for: tier).map { " / \($0) maximum" } ?? " · No limit")")
                                .font(.title3.weight(.semibold)).foregroundStyle(Palette.tier(tier))
                                .accessibilityIdentifier("collection.tier.\(tier.rawValue)")
                            ForEach(collection.channels.filter { $0.tier == tier }) { channel in
                                channelRow(channel)
                            }
                        }
                        .focusSection()
                    }
                    Button("Delete collection", role: .destructive) { confirmDeletion = true }
                        .confirmationDialog("Delete \(collection.name)?", isPresented: $confirmDeletion, titleVisibility: .visible) {
                            Button("Delete collection", role: .destructive) {
                                perform { try model.deleteCollection(collectionID); dismiss() }
                            }
                            .buttonStyle(.automatic)
                        } message: { Text("This removes this collection and its rankings. Saved videos, other collections, and Tristan's original list stay available.") }
                }
                .padding(.horizontal, 90).padding(.vertical, 60)
            }
        }
        .background(Palette.background)
        .sheet(item: $editor) { CollectionNameView(mode: $0) }
        .confirmationDialog("Move \(moving?.name ?? "channel") to a tier", isPresented: $showingMove, titleVisibility: .visible) {
            if let channel = moving {
                ForEach(Tier.allCases) { tier in
                    Button("\(tier.rawValue) tier") { move([channel.id], to: tier) }
                        .buttonStyle(.automatic)
                }
            }
        }
    }

    private func channelRow(_ channel: Channel) -> some View {
        HStack(spacing: 24) {
            if selecting {
                Button {
                    if !selected.insert(channel.id).inserted { selected.remove(channel.id) }
                } label: {
                    Label(channel.name, systemImage: selected.contains(channel.id) ? "checkmark.circle.fill" : "circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityIdentifier("curation.select.\(channel.id)")
            } else {
                NavigationLink(channel.name, value: channel).frame(maxWidth: .infinity, alignment: .leading)
                Button("Move tier", systemImage: "arrow.up.arrow.down") { moving = channel; showingMove = true }
                    .accessibilityLabel("Move \(channel.name) to another tier")
                    .accessibilityIdentifier("curation.move.\(channel.id)")
            }
        }
    }

    private func selectionActions(_ collection: ChannelCollection) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 24) {
                Button("Select all") { selected = Set(collection.channels.map(\.id)) }
                Button("Clear selection") { selected = [] }
                Text("\(selected.count) selected").font(.caption)
            }
            HStack(spacing: 18) {
                ForEach(Tier.allCases) { tier in
                    Button("Move to \(tier.rawValue)") { move(selected, to: tier) }.disabled(selected.isEmpty)
                }
                Button("Remove", role: .destructive) { confirmRemoval = true }.disabled(selected.isEmpty)
                    .confirmationDialog("Remove \(selected.count) channels from this collection?", isPresented: $confirmRemoval, titleVisibility: .visible) {
                        Button("Remove channels", role: .destructive) {
                            perform { try model.editCollection(collectionID) { $0.remove(selected) }; selected = [] }
                        }
                        .buttonStyle(.automatic)
                    }
            }
        }
    }

    private func move(_ ids: Set<String>, to tier: Tier) {
        perform { try model.editCollection(collectionID) { try $0.move(ids, to: tier) }; selected = [] }
    }

    private func perform(_ action: () throws -> Void) {
        do { try action(); error = nil }
        catch { self.error = error.localizedDescription }
    }
}
