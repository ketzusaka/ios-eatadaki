import CoreLocation
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
    func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> SpotInfoDetailed
    func fetchSpot(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> SpotInfoDetailed
    func fetchSpots(request: FetchSpotsDataRequest) async throws(SpotsRepositoryError) -> [SpotInfoSummary]
    func observeSpots(request: FetchSpotsDataRequest) async -> any AsyncSequence<[SpotInfoSummary], SpotsRepositoryError>

    @discardableResult
    func create(spot: SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord

    @discardableResult
    func save(spot: SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord
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

    public func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> SpotInfoDetailed {
        do {
            return try await db.read { db in
                let request = SpotRecord
                    .including(all: SpotRecord.experiences)
                    .filter(id: id)
                guard let spotInfo = try SpotInfoDetailed.fetchOne(db, request) else {
                    throw SpotsRepositoryError.spotNotFound
                }
                return spotInfo
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchSpot(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> SpotInfoDetailed {
        guard ids.hasAnyID else {
            throw SpotsRepositoryError.noIDsProvided
        }

        do {
            return try await db.read { db in
                let condition = try ids.condition

                let request = SpotRecord
                    .including(all: SpotRecord.experiences)
                    .filter(condition)
                guard let spotInfo = try SpotInfoDetailed.fetchOne(db, request) else {
                    throw SpotsRepositoryError.spotNotFound
                }
                return spotInfo
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchSpots(request: FetchSpotsDataRequest = .default) async throws(SpotsRepositoryError) -> [SpotInfoSummary] {
        do {
            return try await db.read { db in
                var baseQuery: QueryInterfaceRequest<SpotRecord>

                if let query = request.query, !query.isEmpty {
                    baseQuery = SpotRecord.filter(Column("name").like("%\(query)%", escape: "\\"))
                } else {
                    baseQuery = SpotRecord.all()
                }

                switch request.sort.field {
                case .name:
                    let ordering = request.sort.direction == .ascending
                        ? Column("name").asc
                        : Column("name").desc
                    let spots = try baseQuery.order(ordering).fetchAll(db)
                    return spots.map { SpotInfoSummary(spot: $0) }

                case .distance(let coordinate):
                    let orderDirection = request.sort.direction == .ascending ? "ASC" : "DESC"
                    let sql: String
                    var arguments: [DatabaseValueConvertible] = []
                    if let query = request.query, !query.isEmpty {
                        sql = """
                            SELECT * FROM spots
                            WHERE name LIKE ?
                            ORDER BY (
                                (latitude - ?) * (latitude - ?) +
                                (longitude - ?) * (longitude - ?)
                            ) \(orderDirection)
                        """
                        arguments.append("%\(query)%")
                    } else {
                        sql = """
                            SELECT * FROM spots
                            ORDER BY (
                                (latitude - ?) * (latitude - ?) +
                                (longitude - ?) * (longitude - ?)
                            ) \(orderDirection)
                        """
                    }
                    arguments.append(contentsOf: [
                        coordinate.latitude,
                        coordinate.latitude,
                        coordinate.longitude,
                        coordinate.longitude,
                    ])
                    let spots = try SpotRecord.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
                    return spots.map { SpotInfoSummary(spot: $0) }
                }
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func observeSpots(request: FetchSpotsDataRequest = .default) async -> any AsyncSequence<[SpotInfoSummary], SpotsRepositoryError> {
        let baseStream: any AsyncSequence<[SpotInfoSummary], Error>
        switch request.sort.field {
        case .name:
            let orderDirection = request.sort.direction == .ascending ? "ASC" : "DESC"
            let sql: String
            var arguments: [DatabaseValueConvertible] = []
            if let searchQuery = request.query, !searchQuery.isEmpty {
                sql = """
                    SELECT * FROM spots
                    WHERE name LIKE ?
                    ORDER BY name \(orderDirection)
                """
                arguments.append("%\(searchQuery)%")
            } else {
                sql = """
                    SELECT * FROM spots
                    ORDER BY name \(orderDirection)
                """
            }
            let observation = ValueObservation.tracking { db in
                try SpotInfoSummary.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            }

            baseStream = observation.values(in: db)
        case .distance(let coordinate):
            let orderDirection = request.sort.direction == .ascending ? "ASC" : "DESC"
            let sql: String
            var arguments: [DatabaseValueConvertible] = []
            if let searchQuery = request.query, !searchQuery.isEmpty {
                sql = """
                    SELECT * FROM spots
                    WHERE name LIKE ?
                    ORDER BY (
                        (latitude - ?) * (latitude - ?) +
                        (longitude - ?) * (longitude - ?)
                    ) \(orderDirection)
                """
                arguments.append("%\(searchQuery)%")
            } else {
                sql = """
                    SELECT * FROM spots
                    ORDER BY (
                        (latitude - ?) * (latitude - ?) +
                        (longitude - ?) * (longitude - ?)
                    ) \(orderDirection)
                """
            }
            arguments.append(contentsOf: [
                coordinate.latitude,
                coordinate.latitude,
                coordinate.longitude,
                coordinate.longitude,
            ])
            let observation = ValueObservation.tracking { db in
                try SpotInfoSummary.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            }

            baseStream = observation.values(in: db)
        }

        return ErrorTransformingSequence<[SpotInfoSummary], SpotsRepositoryError>(
            baseStream: baseStream,
            transformError: { error in
                if let spotsError = error as? SpotsRepositoryError {
                    spotsError
                } else {
                    SpotsRepositoryError.databaseError(error.localizedDescription)
                }
            }
        )
    }

    @discardableResult
    public func create(spot: SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord {
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

    private func fetchSpotRecord(withID id: UUID) async throws(SpotsRepositoryError) -> SpotRecord {
        do {
            return try await db.read { db in
                guard let spot = try SpotRecord.fetchOne(db, key: id) else {
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

    private func fetchSpotRecord(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> SpotRecord {
        guard ids.hasAnyID else {
            throw SpotsRepositoryError.noIDsProvided
        }

        do {
            return try await db.read { db in
                let condition = try ids.condition

                let request = SpotRecord.filter(condition)
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

    @discardableResult
    public func save(spot: SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord {
        let spotIDs = SpotIDs(
            id: spot.id,
            mapkitId: spot.mapkitId,
            remoteId: spot.remoteId
        )

        do {
            // Try to find an existing spot
            var existingSpot = try await fetchSpotRecord(withIDs: spotIDs)
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

    nonisolated private func updateGeospatialIndex(for spot: SpotRecord, in db: Database) throws {
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

extension SpotIDs {
    var condition: SQLSpecificExpressible {
        get throws {
            var condition: SQLSpecificExpressible?

            if let id {
                let idCondition = Column("id") == id
                condition = condition.map { $0 || idCondition } ?? idCondition
            }
            if let mapkitId {
                let mapkitCondition = Column("mapkitId") == mapkitId
                condition = condition.map { $0 || mapkitCondition } ?? mapkitCondition
            }
            if let remoteId {
                let remoteCondition = Column("remoteId") == remoteId
                condition = condition.map { $0 || remoteCondition } ?? remoteCondition
            }

            guard let condition else {
                throw SpotsRepositoryError.noIDsProvided
            }

            return condition
        }
    }
}
