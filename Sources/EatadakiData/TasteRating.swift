import Foundation
import GRDB

public struct TasteRating: Codable {
    public var id: UUID
    public var tasteId: UUID
    public var rating: Int
    public var notes: String?
    public var createdAt: Date
}

extension TasteRating: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "tastes_ratings" }
}

