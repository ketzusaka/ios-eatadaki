import Foundation
import GRDB

public struct Spot: Codable {
    public var id: UUID
    public var name: String
    public var mapkitId: String?
    public var createdAt: Date
}

extension Spot: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "spots" }
}
