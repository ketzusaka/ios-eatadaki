import EatadakiData
import EatadakiUI
import SwiftUI

public typealias ExperiencesViewDependencies = ExperiencesViewModelDependencies

public struct ExperiencesView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: ExperiencesViewModel

    private let dependencies: ExperiencesViewDependencies

    public init(dependencies: ExperiencesViewDependencies) {
        self.dependencies = dependencies
        self.viewModel = ExperiencesViewModel(dependencies: dependencies)
    }

    public var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Experiences")
                .searchable(text: $viewModel.searchQuery, prompt: "Search experiences")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // TODO: Present Filtering UI
                        }, label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        })
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // TODO: Present Sort UI
                        }, label: {
                            Image(systemName: "arrow.up.arrow.down")
                        })
                    }
                }
        }
        .onFirstAppear {
            await viewModel.initialize()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.stage {
        case .uninitialized, .initializing:
            LoadingView()
        case .ready:
            experiencesList
        }
    }

    @ViewBuilder
    private var experiencesList: some View {
        let theme = themeManager.tokens(for: colorScheme)

        List {
            ForEach(viewModel.experiences) { experience in
                Text(experience.name)
                    .listMainTextStyling(using: theme)
            }
        }
    }
}

#if DEBUG
#Preview("Success") {
    let dependencies = FakeExperiencesViewModelDependencies()

    NavigationStack {
        ExperiencesView(dependencies: dependencies)
            .environment(ThemeManager())
    }
}

#Preview("Loading") {
    let dependencies = FakeExperiencesViewModelDependencies {
        $0.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            try? await Task.sleep(nanoseconds: .max)
            return true
        }
    }

    NavigationStack {
        ExperiencesView(dependencies: dependencies)
            .environment(ThemeManager())
    }
}
#endif
