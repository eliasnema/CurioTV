import SwiftUI

struct BrandHeader: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Image(systemName: "sparkle").foregroundStyle(Palette.accent).accessibilityHidden(true)
            Text("curio").font(.title2.weight(.semibold)).tracking(-1)
            Text("TV").font(.caption.weight(.semibold)).foregroundStyle(Palette.accent).tracking(3)
            Spacer()
            Text("GOOD VIDEOS. GREAT RABBIT HOLES.")
                .font(.caption2.weight(.medium)).tracking(3).foregroundStyle(Palette.secondary)
        }
    }
}
