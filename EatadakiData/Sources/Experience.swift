import Foundation
import GRDB

public struct Experience: Codable {
    public var id: UUID
    public var remoteId: String?
    public var name: String
    public var description: String?
    public var createdAt: Date
    
    public init(id: UUID, remoteId: String? = nil, name: String, description: String? = nil, createdAt: Date) {
        self.id = id
        self.remoteId = remoteId
        self.name = name
        self.description = description
        self.createdAt = createdAt
    }
}

extension Experience: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "experiences" }
}
