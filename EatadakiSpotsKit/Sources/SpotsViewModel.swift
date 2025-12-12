import CoreLocation
import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import Foundation
import Observation

public typealias SpotsViewModelDependencies = LocationServiceProviding & DeviceConfigurationControllerProviding & SpotsRepositoryProviding

@Observable
@MainActor
public final class SpotsViewModel {
    public var currentLocation: CLLocation?
    public var spots: [SpotInfoListing] = []
    public var isOptedIn = false
    public var hasInitialized = false
    public var isFetchingLocation = false
    public var hasReceivedContent = false
    public var isFetchingContent = false

    private let dependencies: SpotsViewModelDependencies

    public init(
        dependencies: SpotsViewModelDependencies,
    ) {
        self.dependencies = dependencies
    }

    public func initialize() async {
        // Check opt-in status
        do {
            isOptedIn = try await dependencies.deviceConfigurationController.optInLocationServices
        } catch {
            isOptedIn = false
        }
        
        // Once we know if we can request a location we're considered initialized
        hasInitialized = true

        // If opted in, fetch location
        if isOptedIn {
            await refreshCurrentLocation()
            await refreshSpots()
        }
    }
    
    public func optIntoLocationServices() async {
        do {
            try await dependencies.deviceConfigurationController.setOptInLocationServices(true)
            isOptedIn = true
            await refreshCurrentLocation()
            await refreshSpots()
        } catch {
            // TODO: Handle failure
        }
    }
    
    public func refreshCurrentLocation() async {
        isFetchingLocation = true
        defer { isFetchingLocation = false }

        do {
            currentLocation = try await dependencies.locationService.obtain()
        } catch {
            // TODO: Handle failed location fetch
        }
    }
    
    public func refreshSpots() async {
        isFetchingContent = true
        // TODO: Fetch content!
        try? await Task.sleep(seconds: 3)
        hasReceivedContent = true
        isFetchingContent = false
    }
}

#if DEBUG
public struct FakeSpotsViewModelDependencies: LocationServiceProviding, DeviceConfigurationControllerProviding, SpotsRepositoryProviding {
    public var fakeLocationService = FakeLocationService()
    public var locationService: LocationService { fakeLocationService }
    
    public var fakeDeviceConfigurationController = FakeDeviceConfigurationController()
    public var deviceConfigurationController: DeviceConfigurationController { fakeDeviceConfigurationController }
    
    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: SpotsRepository { fakeSpotsRepository }
    
    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
