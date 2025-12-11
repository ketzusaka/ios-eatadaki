import Foundation
import GRDB

public struct Spot: Codable, Identifiable {
    public var id: UUID
    public var mapkitId: String?
    public var remoteId: String?
    public var name: String
    public var createdAt: Date

    public init(id: UUID, mapkitId: String? = nil, remoteId: String? = nil, name: String, createdAt: Date) {
        self.id = id
        self.mapkitId = mapkitId
        self.remoteId = remoteId
        self.name = name
        self.createdAt = createdAt
    }
}

extension Spot: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "spots" }
}
