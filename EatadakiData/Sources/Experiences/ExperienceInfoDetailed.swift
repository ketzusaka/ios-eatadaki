import Foundation
import GRDB

public struct ExperienceInfoDetailed: FetchableRecord, Decodable, Equatable, Sendable {
    public var spot: SpotRecord
    public var experience: ExperienceRecord
    public var ratingHistory: [ExperienceRatingRecord]

    public init(
        spot: SpotRecord,
        experience: ExperienceRecord,
        ratingHistory: [ExperienceRatingRecord],
    ) {
        self.spot = spot
        self.experience = experience
        self.ratingHistory = ratingHistory
    }

    public init(row: Row) throws {
        experience = try ExperienceRecord(row: row)
        spot = row["spot"]
        ratingHistory = row["experiences_ratings"]
    }
}

