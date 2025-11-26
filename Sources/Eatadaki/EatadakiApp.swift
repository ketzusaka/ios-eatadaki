import SwiftUI

@main
struct EatadakiApp: App {
    @State private var lifecycleController = AppLifecycleController()

    var body: some Scene {
        WindowGroup {
            RootView(lifecycleController: lifecycleController)
        }
    }
}
