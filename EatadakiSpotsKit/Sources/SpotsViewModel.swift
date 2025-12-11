import CoreLocation
import EatadakiData
import EatadakiLocationKit
import Foundation
import Observation

public typealias SpotsViewModelDependencies = LocationServiceProviding & DeviceConfigurationControllerProviding & SpotsRepositoryProviding

@Observable
@MainActor
public final class SpotsViewModel {
    public var spots: [SpotInfoListing] = []
    public var isOptedIn: Bool = false

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

        // If opted in, fetch location
        if isOptedIn {
            // TODO: Fetch Location
        }
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
    
    public init() {}
}
#endif
