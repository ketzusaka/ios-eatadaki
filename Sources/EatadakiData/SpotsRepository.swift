import Foundation
import GRDB

public protocol SpotsRepository: AnyObject {
    func fetchSpot(withID id: UUID) async throws -> Spot
    func fetchSpots() async throws -> [Spot]
    func create(spot: Spot) async throws -> Spot
}

public protocol SpotsRepositoryProviding {
    var spotsRepository: SpotsRepository { get }
}

public actor RealSpotsRepository: SpotsRepository {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func fetchSpot(withID id: UUID) async throws -> Spot {
        do {
            return try await db.read { db in
                guard let spot = try Spot.fetchOne(db, key: id) else {
                    throw RepositoryError.notFound
                }
                return spot
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.unknown(error.localizedDescription)
        }
    }

    public func fetchSpots() async throws -> [Spot] {
        do {
            return try await db.read { db in
                try Spot.fetchAll(db)
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.unknown(error.localizedDescription)
        }
    }

    public func create(spot: Spot) async throws -> Spot {
        do {
            return try await db.write { db in
                try spot.insert(db)
                return spot
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.unknown(error.localizedDescription)
        }
    }
}

public enum RepositoryError: Error, Equatable {
    case notFound
    case unknown(String)
}
