import SwiftUI

struct FocusCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FocusCardLabel(configuration: configuration)
    }
}

private struct FocusCardLabel: View {
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let configuration: ButtonStyleConfiguration

    var body: some View {
        configuration.label
            .background(Palette.surface, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isFocused ? Palette.accent : .white.opacity(0.08), lineWidth: isFocused ? 4 : 1)
            }
            .scaleEffect(reduceMotion ? 1 : (isFocused ? 1.035 : 1))
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: isFocused)
    }
}
