import Foundation
import GRDB

public enum SpotsRepositoryError: Error, Equatable {
    case databaseError(String)
    case spotNotFound
}

public protocol SpotsRepository: AnyObject {
    func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> Spot
    func fetchSpots() async throws(SpotsRepositoryError) -> [Spot]
    func create(spot: Spot) async throws(SpotsRepositoryError) -> Spot
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

    public func create(spot: Spot) async throws(SpotsRepositoryError) -> Spot {
        do {
            return try await db.write { db in
                try spot.insert(db)
                return spot
            }
        } catch let error as SpotsRepositoryError {
            throw error
        } catch {
            throw SpotsRepositoryError.databaseError(error.localizedDescription)
        }
    }
}
