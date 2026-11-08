import CurioCore
import SwiftUI

struct TierLimitEntryView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let collectionID: UUID
    let tier: Tier
    @State private var value: String
    @State private var error: String?

    init(collectionID: UUID, tier: Tier, initialValue: Int) {
        self.collectionID = collectionID
        self.tier = tier
        _value = State(initialValue: String(initialValue))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("\(tier.rawValue) tier maximum").font(.title.weight(.bold))
            TextField("Maximum number of channels", text: $value).autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Text("Enter a positive whole number. Move channels out before setting a limit below the current count.")
                .font(.caption).foregroundStyle(Palette.secondary)
            if let error { Text(error).foregroundStyle(Palette.accent) }
            HStack(spacing: 26) {
                Button("Save limit") {
                    do {
                        guard let number = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw CurationError.invalidLimit }
                        try model.editCollection(collectionID) { try $0.setLimit(number, for: tier) }
                        dismiss()
                    } catch { self.error = error.localizedDescription }
                }
                .buttonStyle(ActionButtonStyle(prominent: true))
                Button("Cancel") { dismiss() }
            }
        }
        .padding(80).frame(maxWidth: 1250)
    }
}
