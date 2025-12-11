#if DEBUG
import CoreLocation
import Foundation

public class FakeLocationService: LocationService {
    public init(_ configure: (FakeLocationService) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invokedCountObtain: Int = 0
    public var stubObtain: () async throws(LocationServiceError) -> CLLocation = {
        CLLocation(latitude: 37.7749, longitude: -122.4194)
    }

    public func obtain() async throws(LocationServiceError) -> CLLocation {
        invokedCountObtain += 1
        return try await stubObtain()
    }
}
#endif
