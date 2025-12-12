import CoreLocation
import EatadakiData
import Foundation

public enum LocationServiceError: Error, Equatable {
    case optedOutOfLocationServices
    case failedToReadOptedIntoLocationServices
    case unknown(String)
    case updateError(LocationManagerProviderError)
}

public protocol LocationService {
    func obtain() async throws(LocationServiceError) -> CLLocation
}

public protocol LocationServiceProviding {
    var locationService: LocationService { get }
}

public actor RealLocationService: LocationService {
    private let deviceConfigurationController: any DeviceConfigurationController
    private let locationManager: any LocationManagerProvider

    private var hasOptedIn = false

    public init(
        deviceConfigurationController: any DeviceConfigurationController,
        locationManager: any LocationManagerProvider = CLLocationManager(),
    ) {
        self.deviceConfigurationController = deviceConfigurationController
        self.locationManager = locationManager
    }

    public func obtain() async throws(LocationServiceError) -> CLLocation {
        /// If we're already authorized by the system we don't need to worry about our own opt-in value.
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            return try await currentLocation()
        }
        
        /// Now lets check if they are opted in
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
        
        /// We've determined they are opted in now. We don't need to ask for permission; our fetch will do that on our behalf.

        return try await currentLocation()
    }
    
    private func currentLocation() async throws(LocationServiceError) -> CLLocation {
        do {
            return try await locationManager.requestLocation()
        } catch {
            throw LocationServiceError.updateError(error)
        }
    }
}
