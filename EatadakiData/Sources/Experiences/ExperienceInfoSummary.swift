import Foundation
import GRDB

public struct ExperienceInfoSummary: FetchableRecord, Decodable, Sendable, Hashable {
    public var spot: SpotRecord
    public var experience: ExperienceRecord

    public init(
        spot: SpotRecord,
        experience: ExperienceRecord,
    ) {
        self.spot = spot
        self.experience = experience
    }

    public init(row: Row) throws {
        experience = try ExperienceRecord(row: row)
        spot = row["spot"]
    }
}
