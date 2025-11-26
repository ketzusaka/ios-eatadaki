import Foundation
import GRDB

public struct User: Codable {
    public var id: UUID
    public var email: String
    public var createdAt: Date
}

extension User: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "user" }
}
