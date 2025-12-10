import EatadakiUI
import SwiftUI

struct RootView: View {
    @Bindable var lifecycleController: AppLifecycleController
    @State private var themeManager = ThemeManager()

    init(lifecycleController: AppLifecycleController) {
        self.lifecycleController = lifecycleController
    }

    var body: some View {
        Group {
            switch lifecycleController.state {
            case .uninitialized, .initializing, .initialized:
                LoadingView()
                    .task {
                        if case .uninitialized = lifecycleController.state {
                            await lifecycleController.beginInitializing()
                        }
                    }
            case .initializationFailure(let error):
                InitializationErrorView(error: error)
            case .unauthenticated(let context):
                InitializedView(context: context, isAuthenticated: false)
            case .authenticated(let context, _):
                InitializedView(context: context, isAuthenticated: true)
            }
        }
        .environment(themeManager)
    }
}
