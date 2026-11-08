import CurioCore
import SwiftUI

struct CollectionNameView: View {
    enum Mode: Identifiable {
        case create(String), rename(ChannelCollection), duplicate(ChannelCollection)
        var id: String {
            switch self {
            case .create: "create"
            case let .rename(value): "rename-\(value.id)"
            case let .duplicate(value): "duplicate-\(value.id)"
            }
        }
        var title: String {
            switch self { case .create: "New collection"; case .rename: "Rename collection"; case .duplicate: "Copy collection" }
        }
        var initialName: String {
            switch self { case let .create(name): name; case let .rename(value): value.name; case let .duplicate(value): "\(value.name) copy" }
        }
    }

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    @State private var name: String
    @State private var copyOriginal = false
    @State private var error: String?

    init(mode: Mode) {
        self.mode = mode
        _name = State(initialValue: mode.initialName)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(mode.title).font(.title.weight(.bold))
            TextField("Collection name", text: $name).autocorrectionDisabled()
                .accessibilityIdentifier("collection.name")
            if case .create = mode {
                Toggle("Start with Tristan's \(model.catalogChannels.count) channels", isOn: $copyOriginal)
                Text("Leave this off to start with an empty collection. You can add channels and groups afterward.")
                    .font(.caption).foregroundStyle(Palette.secondary)
            }
            if let error { Text(error).foregroundStyle(Palette.accent).fixedSize(horizontal: false, vertical: true) }
            HStack(spacing: 26) {
                Button("Save collection") { save() }
                    .buttonStyle(ActionButtonStyle(prominent: true))
                    .accessibilityIdentifier("collection.save")
                Button("Cancel") { dismiss() }
            }
        }
        .padding(80).frame(maxWidth: 1250)
    }

    private func save() {
        do {
            switch mode {
            case .create: try model.createCollection(name: name, channels: copyOriginal ? model.catalogChannels : [])
            case let .rename(collection): try model.renameCollection(collection.id, name: name)
            case let .duplicate(collection): try model.duplicateCollection(collection.id, name: name)
            }
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
