import MapKit

public struct FindSpotsRequest {
    public var location: CLLocation?
    public var query: String?

    public init(location: CLLocation? = nil, query: String? = nil) {
        self.location = location
        self.query = query
    }
}
