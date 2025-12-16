import EatadakiData
import Foundation

public struct FoundSpot {
    public var id: UUID
    public var remoteId: String?
    public var mapkitId: String?
    public var name: String
    public var latitude: Double
    public var longitude: Double

    public init(
        id: UUID,
        remoteId: String? = nil,
        mapkitId: String? = nil,
        name: String,
        latitude: Double,
        longitude: Double,
    ) {
        self.id = id
        self.remoteId = remoteId
        self.mapkitId = mapkitId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

public extension Spot {
    init(from foundSpot: FoundSpot) {
        self.init(
            id: foundSpot.id,
            mapkitId: foundSpot.mapkitId,
            remoteId: foundSpot.remoteId,
            name: foundSpot.name,
            latitude: foundSpot.latitude,
            longitude: foundSpot.longitude,
            createdAt: .now,
            reason: .findResult,
        )
    }
}
