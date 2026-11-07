import SwiftUI

struct PlaybackHelpView: View {
    @Environment(\.dismiss) private var dismiss
    let failure: PlaybackFailure

    var body: some View {
        ScrollView {
          HStack(spacing: 70) {
            VStack(alignment: .leading, spacing: 28) {
                Label("YouTube couldn't be opened", systemImage: "play.slash")
                    .font(.title2.weight(.bold))
                Text("Install the official YouTube app on this Apple TV, then try again.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Text("If the app is installed, this link may not be supported. Search for the video in YouTube or scan the code.")
                    .font(.body).foregroundStyle(Palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(failure.title).font(.headline).fixedSize(horizontal: false, vertical: true)
                if let url = failure.url {
                    Text(url.absoluteString).font(.caption).foregroundStyle(Palette.secondary)
                }
                Button("Back to CurioTV") { dismiss() }.buttonStyle(ActionButtonStyle(prominent: true))
            }
            .frame(maxWidth: 900)
            if let url = failure.url {
                VStack(spacing: 20) {
                    QRCodeView(url: url)
                    Text("Open on your phone").font(.caption).foregroundStyle(Palette.secondary)
                }
            }
          }
          .padding(70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background)
    }
}
