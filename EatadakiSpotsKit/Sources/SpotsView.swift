import CoreLocation
import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import EatadakiUI
import SwiftUI

public struct SpotsView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @Bindable var viewModel: SpotsViewModel

    public init(viewModel: SpotsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Spots")
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
            Text("Spots")
                .headlineTextStyling(using: theme)
        }
    }
}

#if DEBUG
#Preview("Success") {
    let dependencies = FakeSpotsViewModelDependencies()
    let viewModel = SpotsViewModel(dependencies: dependencies)

    NavigationStack {
        SpotsView(viewModel: viewModel)
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
    let viewModel = SpotsViewModel(dependencies: dependencies)

    NavigationStack {
        SpotsView(viewModel: viewModel)
            .environment(ThemeManager())
    }
}

#Preview("Opt-In Required") {
    let dependencies = FakeSpotsViewModelDependencies {
        $0.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            false
        }
    }
    let viewModel = SpotsViewModel(dependencies: dependencies)

    NavigationStack {
        SpotsView(viewModel: viewModel)
            .environment(ThemeManager())
    }
}

#Preview("Locating") {
    let dependencies = FakeSpotsViewModelDependencies {
        $0.fakeLocationService.stubObtain = { () async throws(LocationServiceError) -> CLLocation in
            try? await Task.sleep(nanoseconds: .max)
            return CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
    }
    let viewModel = SpotsViewModel(dependencies: dependencies)

    NavigationStack {
        SpotsView(viewModel: viewModel)
            .environment(ThemeManager())
    }
}
#endif
