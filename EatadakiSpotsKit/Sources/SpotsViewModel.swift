import CoreLocation
import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import Foundation
import Observation

public typealias SpotsViewModelDependencies = LocationServiceProviding & DeviceConfigurationControllerProviding & SpotsRepositoryProviding & SpotsSearcherProviding

@Observable
@MainActor
public final class SpotsViewModel {
    public enum Stage {
        case uninitialized // App hasn't called `initialized()`
        case initializing // Determines opt-in state
        case requiresOptIn // Skipped once the user opts in
        case locating // Locating the user
        case located // User has been located
        case fetching // Fetching content
        case fetched // Fetching finished
    }

    public var stage: Stage = .uninitialized
    public var currentLocation: CLLocation?
    public var spots: [SpotInfoListing] = []
    public var hasReceivedContent = false

    private let dependencies: SpotsViewModelDependencies

    public init(
        dependencies: SpotsViewModelDependencies,
    ) {
        self.dependencies = dependencies
    }

    public func initialize() async {
        // Check opt-in status
        let isOptedIn: Bool
        do {
            isOptedIn = try await dependencies.deviceConfigurationController.optInLocationServices
        } catch {
            isOptedIn = false
        }

        if isOptedIn {
            stage = .locating
            await refreshCurrentLocation()
            await refreshSpots()
        } else {
            stage = .requiresOptIn
        }
    }

    public func optIntoLocationServices() async {
        do {
            try await dependencies.deviceConfigurationController.setOptInLocationServices(true)
            await refreshCurrentLocation()
            await refreshSpots()
        } catch {
            // TODO: Handle failure
        }
    }

    public func refreshCurrentLocation() async {
        do {
            stage = .locating
            currentLocation = try await dependencies.locationService.obtain()
            stage = .located
        } catch {
            // TODO: Handle failed location fetch
        }
    }

    public func refreshSpots() async {
        stage = .fetching
        var request = FindSpotsRequest()
        request.location = currentLocation
        // TODO: Include query text when wired up.
        _ = try? await dependencies.spotsSearcher.findAndCacheSpots(request: request)
        hasReceivedContent = true
        stage = .fetched
    }
}

#if DEBUG
public struct FakeSpotsViewModelDependencies: LocationServiceProviding, DeviceConfigurationControllerProviding, SpotsRepositoryProviding, SpotsSearcherProviding {
    public var fakeLocationService = FakeLocationService()
    public var locationService: LocationService { fakeLocationService }

    public var fakeDeviceConfigurationController = FakeDeviceConfigurationController()
    public var deviceConfigurationController: DeviceConfigurationController { fakeDeviceConfigurationController }

    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: SpotsRepository { fakeSpotsRepository }

    public var fakeSpotsSearcher = FakeSpotsSearcher()
    public var spotsSearcher: SpotsSearcher { fakeSpotsSearcher }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
