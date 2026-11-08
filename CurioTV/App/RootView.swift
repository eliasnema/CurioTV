import CurioCore
import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        TabView {
            Tab("Discover", systemImage: "sparkles") {
                NavigationStack { DiscoverView() }
            }
            Tab("Channels", systemImage: "square.grid.2x2") {
                NavigationStack { ChannelsView() }
            }
            Tab("My Library", systemImage: "bookmark") {
                NavigationStack { LibraryView() }
            }
            Tab("Collections", systemImage: "square.stack") {
                NavigationStack { CollectionsView() }
            }
            Tab("Settings", systemImage: "gearshape") {
                NavigationStack { SettingsView() }
            }
        }
        .background(Palette.background)
        .sheet(item: $model.storageError.message) { message in
            MessageView(title: "Library needs attention", message: message.text)
        }
    }
}

private struct MessageView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 32) {
            Text(title).font(.title)
            Text(message).font(.body).foregroundStyle(Palette.secondary).multilineTextAlignment(.center)
            Button("Close") { dismiss() }
        }
        .padding(80)
        .frame(maxWidth: 1100)
    }
}

private struct StatusMessage: Identifiable {
    var id: String { text }
    let text: String
}

private extension Optional where Wrapped == String {
    var message: StatusMessage? {
        get { map { StatusMessage(text: $0) } }
        set { self = newValue?.text }
    }
}
