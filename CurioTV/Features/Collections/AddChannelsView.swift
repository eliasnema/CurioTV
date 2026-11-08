import CurioCore
import SwiftUI

struct AddChannelsView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let collectionID: UUID
    @State private var query = ""
    @State private var sourceID: UUID?
    @State private var choosingSource = false
    @State private var tier: Tier?
    @State private var selected: Set<String> = []
    @State private var error: String?

    private var source: [Channel] { model.collection(sourceID)?.channels ?? model.catalogChannels }
    private var filtered: [Channel] { source.filter { $0.matches(query) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Text("Add channels or a whole group.").font(.title.weight(.bold))
                Button("From: \(model.collection(sourceID)?.name ?? "Tristan's collection")") { choosingSource = true }
                    .confirmationDialog("Copy channels from", isPresented: $choosingSource, titleVisibility: .visible) {
                        Button("Tristan's collection") { chooseSource(nil) }.buttonStyle(.automatic)
                        ForEach(model.curation.collections.filter { $0.id != collectionID }) { collection in
                            Button(collection.name) { chooseSource(collection.id) }.buttonStyle(.automatic)
                        }
                    }
                TextField("Search channels", text: $query).autocorrectionDisabled()
                    .accessibilityIdentifier("curation.search")
                TierChoiceRow(selection: $tier, allowOriginal: true)
                HStack(spacing: 24) {
                    Button("Add selected (\(selected.count))") { add() }
                        .buttonStyle(ActionButtonStyle(prominent: true))
                        .disabled(selected.isEmpty)
                        .accessibilityIdentifier("curation.addSelected")
                    Button("Select all shown") { selected.formUnion(filtered.map(\.id)) }
                        .accessibilityIdentifier("curation.selectAll")
                    Button("Clear selection") { selected = [] }
                }
                Text("Choose several channels, or select all shown to copy a group. Existing channels are updated; tier limits apply to the whole change.")
                    .font(.caption).foregroundStyle(Palette.secondary)
                if let error { Text(error).foregroundStyle(Palette.accent).fixedSize(horizontal: false, vertical: true) }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 24) {
                    ForEach(filtered) { channel in
                        Button {
                            if !selected.insert(channel.id).inserted { selected.remove(channel.id) }
                        } label: {
                            Label("\(channel.name) · \(channel.tier.rawValue)", systemImage: selected.contains(channel.id) ? "checkmark.circle.fill" : "circle")
                                .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .accessibilityIdentifier("curation.pick.\(channel.id)")
                        .accessibilityValue(selected.contains(channel.id) ? "Selected" : "Not selected")
                    }
                }
            }
            .padding(.horizontal, 90).padding(.vertical, 50)
        }
        .background(Palette.background)
    }

    private func chooseSource(_ id: UUID?) { sourceID = id; selected = []; query = ""; error = nil }

    private func add() {
        do {
            let channels = source.filter { selected.contains($0.id) }
            try model.editCollection(collectionID) { try $0.add(channels, tier: tier) }
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
