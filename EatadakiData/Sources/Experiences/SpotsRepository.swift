import Foundation
import GRDB

public enum SpotsRepositoryError: Error, Equatable {
    case databaseError(String)
    case spotNotFound
    case noIDsProvided
}

public struct SpotIDs: Equatable {
    public let id: UUID?
    public let mapkitId: String?
    public let remoteId: String?

    public init(id: UUID? = nil, mapkitId: String? = nil, remoteId: String? = nil) {
        self.id = id
        self.mapkitId = mapkitId
        self.remoteId = remoteId
    }

    public var hasAnyID: Bool {
        id != nil || mapkitId != nil || remoteId != nil
    }
}

public protocol SpotsRepository: AnyObject {
    func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> Spot
    func fetchSpot(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> Spot
    func fetchSpots() async throws(SpotsRepositoryError) -> [Spot]

    @discardableResult
    func create(spot: Spot) async throws(SpotsRepositoryError) -> Spot

    @discardableResult
    func save(spot: Spot) async throws(SpotsRepositoryError) -> Spot
}

public protocol SpotsRepositoryDependencies {
    var experiencesDataService: ExperiencesDataService { get }
}

public protocol SpotsRepositoryProviding {
    var spotsRepository: SpotsRepository { get }
}

public actor RealSpotsRepository: SpotsRepository {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> Spot {
        do {
            return try await db.read { db in
                guard let spot = try Spot.fetchOne(db, key: id) else {
                    throw SpotsRepositoryError.spotNotFound
                }
                return spot
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchSpot(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> Spot {
        guard ids.hasAnyID else {
            throw SpotsRepositoryError.noIDsProvided
        }

        do {
            return try await db.read { db in
                var condition: SQLSpecificExpressible?

                if let id = ids.id {
                    let idCondition = Column("id") == id
                    condition = condition.map { $0 || idCondition } ?? idCondition
                }
                if let mapkitId = ids.mapkitId {
                    let mapkitCondition = Column("mapkitId") == mapkitId
                    condition = condition.map { $0 || mapkitCondition } ?? mapkitCondition
                }
                if let remoteId = ids.remoteId {
                    let remoteCondition = Column("remoteId") == remoteId
                    condition = condition.map { $0 || remoteCondition } ?? remoteCondition
                }

                guard let condition else {
                    throw SpotsRepositoryError.noIDsProvided
                }

                let request = Spot.filter(condition)
                guard let spot = try request.fetchOne(db) else {
                    throw SpotsRepositoryError.spotNotFound
                }
                return spot
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchSpots() async throws(SpotsRepositoryError) -> [Spot] {
        do {
            return try await db.read { db in
                try Spot.fetchAll(db)
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    @discardableResult
    public func create(spot: Spot) async throws(SpotsRepositoryError) -> Spot {
        do {
            return try await db.write { [weak self] db in
                try spot.insert(db)
                try self?.updateGeospatialIndex(for: spot, in: db)
                return spot
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    @discardableResult
    public func save(spot: Spot) async throws(SpotsRepositoryError) -> Spot {
        let spotIDs = SpotIDs(
            id: spot.id,
            mapkitId: spot.mapkitId,
            remoteId: spot.remoteId
        )

        do {
            // Try to find an existing spot
            var existingSpot = try await fetchSpot(withIDs: spotIDs)
            existingSpot.update(with: spot)

            return try await db.write { [existingSpot, weak self] db in
                try existingSpot.update(db)
                try self?.updateGeospatialIndex(for: existingSpot, in: db)
                return existingSpot
            }
        } catch SpotsRepositoryError.spotNotFound {
            // Spot doesn't exist, create it
            return try await create(spot: spot)
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    nonisolated private func updateGeospatialIndex(for spot: Spot, in db: Database) throws {
        let spotIdString = spot.id.uuidString
        let longitude = spot.longitude
        let latitude = spot.latitude

        // Check if entry already exists
        let existingEntry = try Row.fetchOne(
            db,
            sql: "SELECT id FROM spots_geospatial_index WHERE spotId = ?",
            arguments: [spotIdString]
        )

        if existingEntry != nil {
            // Update existing entry
            try db.execute(
                sql: """
                    UPDATE spots_geospatial_index
                    SET minX = ?, maxX = ?, minY = ?, maxY = ?
                    WHERE spotId = ?
                """,
                arguments: [longitude, longitude, latitude, latitude, spotIdString]
            )
        } else {
            // Insert new entry (id is NULL to auto-generate)
            try db.execute(
                sql: """
                    INSERT INTO spots_geospatial_index (id, minX, maxX, minY, maxY, spotId)
                    VALUES (NULL, ?, ?, ?, ?, ?)
                """,
                arguments: [longitude, longitude, latitude, latitude, spotIdString]
            )
        }
    }

    nonisolated private func deleteFromGeospatialIndex(spotId: UUID, in db: Database) throws {
        let spotIdString = spotId.uuidString
        try db.execute(
            sql: "DELETE FROM spots_geospatial_index WHERE spotId = ?",
            arguments: [spotIdString]
        )
    }
}
