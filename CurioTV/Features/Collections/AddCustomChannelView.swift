import CurioCore
import SwiftUI

struct AddCustomChannelView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let collectionID: UUID
    @State private var name = ""
    @State private var link = ""
    @State private var tier: Tier? = .b
    @State private var error: String?
    @State private var isAdding = false
    @State private var requestID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Add a YouTube channel.").font(.title.weight(.bold))
                TextField("Channel name", text: $name).autocorrectionDisabled()
                    .accessibilityIdentifier("curation.channelName")
                TextField("YouTube channel link or @handle", text: $link).autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier("curation.channelLink")
                Text("Use your iPhone's Apple TV keyboard for longer links. CurioTV checks the channel's public RSS link to find recent uploads. If that lookup is unavailable, the channel can still open in YouTube.")
                    .font(.caption).foregroundStyle(Palette.secondary)
                TierChoiceRow(selection: $tier)
                if let error { Text(error).foregroundStyle(Palette.accent).fixedSize(horizontal: false, vertical: true) }
                Button { requestID = UUID() } label: {
                    Text("Add channel").frame(maxWidth: .infinity)
                }
                    .buttonStyle(ActionButtonStyle(prominent: true))
                    .accessibilityIdentifier("curation.addCustom")
                    .disabled(isAdding)
                if isAdding { ProgressView("Finding the public channel feed…") }
            }
            .padding(.horizontal, 90).padding(.vertical, 60)
        }
        .background(Palette.background)
        .task(id: requestID) {
            if requestID != nil { await add() }
        }
    }

    private func add() async {
        guard !isAdding else { return }
        isAdding = true
        defer { isAdding = false }
        do {
            let address = try ChannelAddress(link)
            let channel: Channel
            if let known = model.allChannels.first(where: { $0.id == address.id || $0.url == address.url }) {
                channel = known.ranked(tier ?? .b)
            } else {
                let candidate = try address.channel(name: name, tier: tier ?? .b)
                let resolved = await model.feedDiscovery.discover(for: candidate)
                try Task.checkCancellation()
                channel = model.allChannels.first(where: { $0.id == resolved.id })?.ranked(tier ?? .b) ?? resolved
            }
            try model.editCollection(collectionID) { try $0.add([channel]) }
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
