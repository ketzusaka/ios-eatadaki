import Foundation
import GRDB

public struct ExperienceRating: Codable {
    public var id: UUID
    public var experienceId: UUID
    public var rating: Int
    public var notes: String?
    public var createdAt: Date
}

extension ExperienceRating: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "experiences_ratings" }
}
