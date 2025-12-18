import Foundation
import GRDB

public enum SpotReason: String, Codable, Sendable {
    case createdByUser = "createdByUser"
    case findResult = "findResult"
    case foundAndViewed = "foundAndViewed"
}

public struct Spot: Codable, Identifiable, Sendable {
    public var id: UUID
    public var mapkitId: String?
    public var remoteId: String?
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var createdAt: Date
    public var reason: SpotReason

    public init(
        id: UUID,
        mapkitId: String? = nil,
        remoteId: String? = nil,
        name: String,
        latitude: Double,
        longitude: Double,
        createdAt: Date,
        reason: SpotReason = .findResult,
    ) {
        self.id = id
        self.mapkitId = mapkitId
        self.remoteId = remoteId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.reason = reason
    }
}

extension Spot: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "spots" }
    
    public static let experiences = hasMany(Experience.self)

    public mutating func update(with spot: Spot) {
        self.name = spot.name
        self.latitude = spot.latitude
        self.longitude = spot.longitude
        self.remoteId = spot.remoteId
    }
}
