import Foundation
import CoreLocation

public enum LocationServiceError: Error {
    case unconfigured
}

public protocol LocationService: AnyObject {
    func obtain() async throws -> CLLocation
}

public protocol LocationServiceProviding {
    var locationService: LocationService { get }
}

