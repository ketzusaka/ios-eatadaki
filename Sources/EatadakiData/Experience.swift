import Foundation
import GRDB

public struct Experience: Codable {
    public var id: UUID
    public var remoteId: String?
    public var name: String
    public var description: String?
    public var createdAt: Date
}

extension Experience: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "experiences" }
}
