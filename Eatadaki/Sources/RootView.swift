import EatadakiKit
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
            case .uninitialized, .initializing:
                LoadingView()
                    .task {
                        if case .uninitialized = lifecycleController.state {
                            await lifecycleController.beginInitializing()
                        }
                    }
            case .initializationFailure(let error):
                SimpleInterstitialView(
                    title: "Initialization Failed",
                    description: error,
                    imageSystemName: "exclamationmark.triangle",
                )
            case .initialized(let context):
                InitializedView(context: context)
            }
        }
        .environment(themeManager)
    }
}

#if DEBUG
#Preview("Initialization Success") {
    RootView(lifecycleController: AppLifecycleController())
}

#Preview("Initialization Failure") {
    let fakeFileSystem = FakeFileSystemProvider {
        $0.stubUrlForInAppropriateForCreate = { _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create application support directory"])
        }
    }

    RootView(lifecycleController: AppLifecycleController(fileSystemProvider: fakeFileSystem))
}
#endif
