import CoreLocation
import EatadakiData
import Foundation

public enum LocationServiceError: Error, Equatable {
    case optedOutOfLocationServices
    case failedToReadOptedIntoLocationServices
    case unknown(String)
}

public protocol LocationService {
    func obtain() async throws(LocationServiceError) -> CLLocation
}

public protocol LocationServiceProviding {
    var locationService: LocationService { get }
}

public actor RealLocationService: LocationService {
    private let deviceConfigurationController: any DeviceConfigurationController
    private var hasOptedIn = false

    public init(deviceConfigurationController: any DeviceConfigurationController) {
        self.deviceConfigurationController = deviceConfigurationController
    }

    public func obtain() async throws(LocationServiceError) -> CLLocation {
        let isOptedIn: Bool

        if !hasOptedIn {
            do {
                isOptedIn = try await deviceConfigurationController.optInLocationServices
                if isOptedIn {
                    hasOptedIn = true
                }
            } catch {
                throw LocationServiceError.failedToReadOptedIntoLocationServices
            }
        } else {
            isOptedIn = true
        }

        guard isOptedIn else {
            throw LocationServiceError.optedOutOfLocationServices
        }

        // TODO: Implement the rest
        throw LocationServiceError.unknown("Not implemented")
    }
}
