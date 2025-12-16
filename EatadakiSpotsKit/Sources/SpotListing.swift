import EatadakiData
import Foundation
import MapKit

public struct SpotInfoListing: Identifiable {
    public let id: UUID
    public let coordinates: CLLocationCoordinate2D

    public init(from spot: Spot) {
        self.id = spot.id
        self.coordinates = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
    }
}
