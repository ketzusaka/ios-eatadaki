import EatadakiData
import EatadakiLocationKit
import Foundation
import MapKit

public struct SpotInfoDetailed: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var coordinates: Coordinates

    public init(from spot: SpotRecord) {
        self.id = spot.id
        self.name = spot.name
        self.coordinates = Coordinates(latitude: spot.latitude, longitude: spot.longitude)
    }
}
