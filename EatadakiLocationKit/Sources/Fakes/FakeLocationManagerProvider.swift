#if DEBUG
import CoreLocation
import Foundation

public class FakeLocationManagerProvider: LocationManagerProvider {
    public init(_ configure: (FakeLocationManagerProvider) -> Void = { _ in }) {
        configure(self)
    }

    public var stubAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    public var authorizationStatus: CLAuthorizationStatus {
        stubAuthorizationStatus
    }

    public var invokedCountRequestWhenInUseAuthorization: Int = 0
    public var stubRequestWhenInUseAuthorization: () -> Void = { }

    public func requestWhenInUseAuthorization() {
        invokedCountRequestWhenInUseAuthorization += 1
        stubRequestWhenInUseAuthorization()
    }

    public var invokedCountRequestLocation: Int = 0
    public var stubRequestLocation: () async throws(LocationManagerProviderError) -> CLLocation = { CLLocation(latitude: -122.4194, longitude: 37.7749) }

    public func requestLocation() async throws(LocationManagerProviderError) -> CLLocation {
        invokedCountRequestLocation += 1
        return try await stubRequestLocation()
    }
}
#endif
