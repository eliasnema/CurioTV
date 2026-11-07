import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var prominent = false

    func makeBody(configuration: Configuration) -> some View {
        ActionButtonLabel(configuration: configuration, prominent: prominent)
    }
}

private struct ActionButtonLabel: View {
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let configuration: ButtonStyleConfiguration
    let prominent: Bool

    var body: some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(isFocused || prominent ? Palette.background : .white)
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .background(isFocused ? .white : (prominent ? Palette.accent : Palette.surface), in: .capsule)
            .overlay {
                Capsule().strokeBorder(isFocused ? Palette.accent : .white.opacity(0.12), lineWidth: isFocused ? 3 : 1)
            }
            .scaleEffect(reduceMotion ? 1 : (isFocused ? 1.025 : 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: isFocused)
    }
}
