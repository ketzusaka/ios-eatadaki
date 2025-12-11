import CoreLocation
import EatadakiData
import EatadakiLocationKit
import Foundation
import Observation

public typealias SpotsViewModelDependencies = LocationServiceProviding & DeviceConfigurationControllerProviding & SpotsRepositoryProviding

@Observable
@MainActor
public final class SpotsViewModel {
    var location: CLLocation?
    var spots: [Spot] = []
    var searchQuery: String = ""
    var isLoadingLocation: Bool = false
    var locationError: Error?
    var isOptedIn: Bool = false
    var hasInitialized: Bool = false

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

        hasInitialized = true
    }
}
