import Foundation
import GRDB

public struct ExperienceRecord: Codable, Sendable {
    public var id: UUID
    public var spotId: UUID
    public var remoteId: String?
    public var name: String
    public var description: String?
    public var createdAt: Date

    public init(id: UUID, spotId: UUID, remoteId: String? = nil, name: String, description: String? = nil, createdAt: Date) {
        self.id = id
        self.spotId = spotId
        self.remoteId = remoteId
        self.name = name
        self.description = description
        self.createdAt = createdAt
    }
}

extension ExperienceRecord: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "experiences" }

    public static let spot = belongsTo(
        SpotRecord.self,
        using: ForeignKey(["spotId"])
    )

    public static let ratings = hasMany(
        ExperienceRatingRecord.self,
        using: ForeignKey(["experienceId"])
    )
}
