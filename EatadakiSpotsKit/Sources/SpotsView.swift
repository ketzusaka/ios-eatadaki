import CoreLocation
import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import EatadakiUI
import SwiftUI

public struct SpotsView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: SpotsViewModel

    public init(dependencies: SpotsViewModelDependencies) {
        self.viewModel = SpotsViewModel(dependencies: dependencies)
    }

    public var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Spots")
                .searchable(text: $viewModel.searchQuery, prompt: "Search spots")
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
                            // TODO: Add spot
                        }, label: {
                            Image(systemName: "plus")
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
        case .requiresOptIn:
            locationOptInInterstitial
        case .locating:
            if viewModel.hasReceivedContent {
                spotsList
            } else {
                LoadingView(text: "Locating")
            }
        case .located, .fetching, .fetched:
            if viewModel.hasReceivedContent {
                spotsList
            } else {
                LoadingView(text: "Finding spots")
            }
        }
    }

    private var locationOptInInterstitial: some View {
        SimpleInterstitialView(
            title: "Location Services Required",
            description: "We need your location to find nearby spots. Please enable location services to continue.",
            imageSystemName: "location.circle",
            style: .notice,
            actions: [
                SimpleInterstitialView.Action(
                    label: "Enable Location Services",
                    style: .primary,
                ) {
                    await viewModel.optIntoLocationServices()
                }
            ]
        )
    }

    @ViewBuilder
    private var spotsList: some View {
        let theme = themeManager.tokens(for: colorScheme)

        List {
            ForEach(viewModel.spots) { spot in
                Text(spot.name)
                    .listMainTextStyling(using: theme)
            }
        }
    }
}

#if DEBUG
#Preview("Success") {
    let dependencies = FakeSpotsViewModelDependencies()

    NavigationStack {
        SpotsView(dependencies: dependencies)
            .environment(ThemeManager())
    }
}

#Preview("Loading") {
    let dependencies = FakeSpotsViewModelDependencies {
        $0.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            try? await Task.sleep(nanoseconds: .max)
            return true
        }
    }

    NavigationStack {
        SpotsView(dependencies: dependencies)
            .environment(ThemeManager())
    }
}

#Preview("Opt-In Required") {
    let dependencies = FakeSpotsViewModelDependencies {
        $0.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            false
        }
    }

    NavigationStack {
        SpotsView(dependencies: dependencies)
            .environment(ThemeManager())
    }
}

#Preview("Locating") {
    let dependencies = FakeSpotsViewModelDependencies {
        $0.fakeLocationService.stubObtain = { () async throws(LocationServiceError) -> CLLocation in
            try? await Task.sleep(nanoseconds: .max)
            return CLLocation(latitude: 37.7850, longitude: -122.4294)
        }
    }

    NavigationStack {
        SpotsView(dependencies: dependencies)
            .environment(ThemeManager())
    }
}
#endif
