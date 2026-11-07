import CurioCore
import SwiftUI

struct TierBadge: View {
    let tier: Tier

    var body: some View {
        Text("\(tier.rawValue) TIER")
            .font(.caption2.weight(.bold))
            .tracking(2)
            .foregroundStyle(Palette.tier(tier))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Palette.tier(tier).opacity(0.13), in: .rect(cornerRadius: 7))
            .accessibilityLabel("Tier \(tier.rawValue)")
    }
}
