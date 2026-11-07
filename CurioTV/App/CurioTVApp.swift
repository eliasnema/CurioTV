import SwiftUI

@main
struct CurioTVApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .preferredColorScheme(.dark)
                .buttonStyle(ActionButtonStyle())
        }
    }
}
