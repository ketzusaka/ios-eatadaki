import EatadakiData
import EatadakiUI
import SwiftUI

public typealias ExperiencesViewDependencies = ExperiencesViewModelDependencies & SpotsRepositoryProviding

public struct ExperiencesView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: ExperiencesViewModel
    @State var navPath: [ExperiencesScreen] = []

    private let dependencies: ExperiencesViewDependencies

    public init(dependencies: ExperiencesViewDependencies) {
        self.dependencies = dependencies
        self.viewModel = ExperiencesViewModel(dependencies: dependencies)
    }

    public var body: some View {
        NavigationStack(path: $navPath) {
            contentView
                .navigationDestination(for: ExperiencesScreen.self) { screen in
                    switch screen {
                    case .experienceDetils(let data):
                        switch data {
                        case .id(let id):
                            ExperienceDetailView(dependencies: dependencies, experienceId: id)
                        case .summary(let summary):
                            ExperienceDetailView(dependencies: dependencies, experienceSummary: summary)
                        }
                    case .spotDetails(let data):
                        switch data {
                        case .id(let id):
                            SpotDetailView(dependencies: dependencies, spotId: id)
                        case .summary(let summary):
                            SpotDetailView(dependencies: dependencies, spotSummary: summary)
                        }
                    }
                }
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
        List {
            ForEach(viewModel.experiences) { experience in
                NavigationLink(value: ExperiencesScreen.experienceDetils(.summary(experience.backingData))) {
                    ExperienceRowView(experience: experience.backingData)
                }
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
