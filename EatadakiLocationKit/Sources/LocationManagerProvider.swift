import CoreLocation
import Foundation

public enum LocationManagerProviderError: Error, Equatable {
    case liveUpdateError(String)
    case locationNotDetermined
}

public protocol LocationManagerProvider {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization()
    func requestLocation() async throws(LocationManagerProviderError) -> CLLocation
}

extension CLLocationManager: LocationManagerProvider {
    public func requestLocation() async throws(LocationManagerProviderError) -> CLLocation {
        let updates = CLLocationUpdate.liveUpdates()
        do {
            for try await update in updates {
                if let location = update.location {
                    return location
                }
            }

            throw LocationManagerProviderError.locationNotDetermined
        } catch let error as LocationManagerProviderError {
            throw error
        } catch {
            throw LocationManagerProviderError.liveUpdateError(error.localizedDescription)
        }
    }
}
