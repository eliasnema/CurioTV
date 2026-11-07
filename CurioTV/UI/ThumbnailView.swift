import SwiftUI

struct ThumbnailView: View {
    let url: URL?
    let title: String

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ZStack {
                LinearGradient(colors: [Palette.surface, Color(red: 0.12, green: 0.19, blue: 0.24)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Text(title.prefix(2).uppercased())
                    .font(.largeTitle.weight(.light))
                    .foregroundStyle(Palette.accent.opacity(0.65))
            }
        }
        .accessibilityHidden(true)
    }
}
