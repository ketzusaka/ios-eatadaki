import Foundation
import GRDB

public struct UserRecord: Codable, Equatable {
    public var id: UUID
    public var email: String
    public var createdAt: Date

    public init(id: UUID, email: String, createdAt: Date) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }
}

extension UserRecord: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "user" }
}
