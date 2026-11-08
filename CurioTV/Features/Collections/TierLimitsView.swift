import CurioCore
import SwiftUI

struct TierLimitsView: View {
    @Environment(AppModel.self) private var model
    let collectionID: UUID
    @State private var selectedTier: Tier?
    @State private var showingLimit = false
    @State private var editingTier: Tier?
    @State private var error: String?
    private let choices = [1, 2, 3, 5, 10, 15, 20, 25, 50, 100]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Keep each tier manageable.").font(.title.weight(.bold))
                Text("Optional maximum channels per tier in this collection. A full tier blocks additions and moves; channels are never removed automatically.")
                    .foregroundStyle(Palette.secondary)
                if let collection = model.collection(collectionID) {
                    ForEach(Tier.allCases) { tier in
                        Button {
                            selectedTier = tier
                            showingLimit = true
                        } label: {
                            HStack {
                                Text("\(tier.rawValue) tier · \(collection.count(in: tier)) channels")
                                Spacer()
                                Text(collection.limit(for: tier).map { "Maximum \($0)" } ?? "No limit")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .accessibilityIdentifier("curation.limit.\(tier.rawValue)")
                    }
                }
                if let error { Text(error).foregroundStyle(Palette.accent).fixedSize(horizontal: false, vertical: true) }
            }
            .padding(.horizontal, 90).padding(.vertical, 60)
        }
        .background(Palette.background)
        .confirmationDialog("Maximum channels in \(selectedTier?.rawValue ?? "") tier", isPresented: $showingLimit, titleVisibility: .visible) {
            if let tier = selectedTier {
                Button("No limit") { set(nil, for: tier) }.buttonStyle(.automatic)
                Button("Custom maximum…") { editingTier = tier }.buttonStyle(.automatic)
                ForEach(choices, id: \.self) { limit in
                    Button("\(limit) \(limit == 1 ? "channel" : "channels")") { set(limit, for: tier) }
                        .buttonStyle(.automatic)
                }
            }
        }
        .sheet(item: $editingTier) { tier in
            TierLimitEntryView(collectionID: collectionID, tier: tier,
                initialValue: model.collection(collectionID)?.limit(for: tier) ?? max(5, model.collection(collectionID)?.count(in: tier) ?? 0))
        }
    }

    private func set(_ limit: Int?, for tier: Tier) {
        do { try model.editCollection(collectionID) { try $0.setLimit(limit, for: tier) }; error = nil }
        catch { self.error = error.localizedDescription }
    }
}
