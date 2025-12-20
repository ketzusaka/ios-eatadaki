import Foundation
import GRDB

public struct ExperienceRatingRecord: Codable {
    public var id: UUID
    public var experienceId: UUID
    public var rating: Int
    public var notes: String?
    public var createdAt: Date

    public init(id: UUID, experienceId: UUID, rating: Int, notes: String? = nil, createdAt: Date) {
        self.id = id
        self.experienceId = experienceId
        self.rating = rating
        self.notes = notes
        self.createdAt = createdAt
    }
}

extension ExperienceRatingRecord: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "experiences_ratings" }

    public static let experience = belongsTo(
        ExperienceRecord.self,
        using: ForeignKey(["experienceId"])
    )
}
