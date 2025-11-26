import Foundation
import GRDB

public struct Taste: Codable {
    public var id: UUID
    public var remoteId: String?
    public var name: String
    public var description: String?
    public var createdAt: Date
}

extension Taste: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "tastes" }
}

