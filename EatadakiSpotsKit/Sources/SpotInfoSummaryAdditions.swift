import EatadakiData
import EatadakiLocationKit

extension SpotInfoSummary {
    public var coordinates: Coordinates {
        Coordinates(latitude: spot.latitude, longitude: spot.longitude)
    }
}
