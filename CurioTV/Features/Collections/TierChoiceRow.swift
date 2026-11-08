import CurioCore
import SwiftUI

struct TierChoiceRow: View {
    @Binding var selection: Tier?
    var allowOriginal = false

    var body: some View {
        HStack(spacing: 18) {
            if allowOriginal { choice(nil) }
            ForEach(Tier.allCases) { tier in choice(tier) }
        }
        .focusSection()
    }

    private func choice(_ tier: Tier?) -> some View {
        Button(tier.map { "\($0.rawValue) tier" } ?? "Keep tiers") { selection = tier }
            .buttonStyle(ActionButtonStyle(prominent: selection == tier))
            .accessibilityAddTraits(selection == tier ? [.isSelected] : [])
            .accessibilityIdentifier("curation.tier.\(tier?.rawValue ?? "original")")
    }
}
