import Foundation
import GRDB

public struct SpotDetailInfo: FetchableRecord, Decodable, Sendable {
    public var spot: Spot
    public var experiences: [Experience]

    public init(
        spot: Spot,
        experiences: [Experience],
    ) {
        self.spot = spot
        self.experiences = experiences
    }
}
