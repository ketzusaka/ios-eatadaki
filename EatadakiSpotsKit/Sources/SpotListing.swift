import EatadakiData
import Foundation
import MapKit

public struct SpotInfoListing: Identifiable {
    public var id: UUID
    public var name: String
    public var coordinates: CLLocationCoordinate2D

    public init(from spot: Spot) {
        self.id = spot.id
        self.name = spot.name
        self.coordinates = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
    }
}
