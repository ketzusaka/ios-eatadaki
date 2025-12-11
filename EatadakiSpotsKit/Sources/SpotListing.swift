import EatadakiData
import Foundation

public struct SpotInfoListing: Identifiable {
    public let id: UUID
    
    public init(from spot: Spot) {
        self.id = spot.id
    }
}
