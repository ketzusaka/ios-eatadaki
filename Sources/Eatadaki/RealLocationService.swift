import Foundation
import CoreLocation
import EatadakiData
import EatadakiKit

public actor RealLocationService: LocationService {
    private let deviceConfigurationController: any DeviceConfigurationController

    public init(deviceConfigurationController: any DeviceConfigurationController) {
        self.deviceConfigurationController = deviceConfigurationController
    }

    public func obtain() async throws -> CLLocation {
        // Check if location services are opted in
        let isOptedIn = try await deviceConfigurationController.optInLocationServices
        
        guard isOptedIn else {
            throw LocationServiceError.unconfigured
        }
        
        // TODO: Implement the rest
        throw LocationServiceError.unconfigured

    }

}
