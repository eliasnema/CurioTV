import CurioCore
import SwiftUI

struct CollectionSwitcher: View {
    @Environment(AppModel.self) private var model
    @State private var showingChoices = false
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button("Collection: \(model.collectionName)", systemImage: "square.stack") { showingChoices = true }
                .accessibilityIdentifier("collection.switch")
                .confirmationDialog("Choose a collection", isPresented: $showingChoices, titleVisibility: .visible) {
                    Button("Tristan's collection") { select(nil) }.buttonStyle(.automatic)
                    ForEach(model.curation.collections) { collection in
                        Button(collection.name) { select(collection.id) }.buttonStyle(.automatic)
                    }
                } message: { Text("Create and edit your own collections in the Collections tab.") }
            if let error { Text(error).font(.caption).foregroundStyle(Palette.accent) }
        }
    }

    private func select(_ id: UUID?) {
        do { try model.selectCollection(id); error = nil }
        catch { self.error = error.localizedDescription }
    }
}
