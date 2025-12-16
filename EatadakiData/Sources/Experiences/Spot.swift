import Foundation
import GRDB

public struct Spot: Codable, Identifiable {
    public var id: UUID
    public var mapkitId: String?
    public var remoteId: String?
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var createdAt: Date

    public init(
        id: UUID,
        mapkitId: String? = nil,
        remoteId: String? = nil,
        name: String,
        latitude: Double,
        longitude: Double,
        createdAt: Date,
    ) {
        self.id = id
        self.mapkitId = mapkitId
        self.remoteId = remoteId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
}

extension Spot: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "spots" }

    public mutating func update(with spot: Spot) {
        self.name = spot.name
        self.latitude = spot.latitude
        self.longitude = spot.longitude
        self.remoteId = spot.remoteId
    }
}
