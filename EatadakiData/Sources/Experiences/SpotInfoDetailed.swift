import Foundation
import GRDB

public struct SpotInfoDetailed: FetchableRecord, Decodable, Sendable {
    public var spot: SpotRecord
    public var experiences: [ExperienceRecord]

    public init(
        spot: SpotRecord,
        experiences: [ExperienceRecord],
    ) {
        self.spot = spot
        self.experiences = experiences
    }
}
