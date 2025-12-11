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
    public var locationService: LocationService = FakeLocationService()
    public var deviceConfigurationController: DeviceConfigurationController = FakeDeviceConfigurationController()
    public var spotsRepository: SpotsRepository = FakeSpotsRepository()
}
#endif
