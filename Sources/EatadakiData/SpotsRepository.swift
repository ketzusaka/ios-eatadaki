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
        try await db.read { db in
            guard let spot = try Spot.fetchOne(db, key: id) else {
                throw RepositoryError.notFound
            }
            return spot
        }
    }

    public func fetchSpots() async throws -> [Spot] {
        try await db.read { db in
            try Spot.fetchAll(db)
        }
    }

    public func create(spot: Spot) async throws -> Spot {
        try await db.write { db in
            try spot.insert(db)
            return spot
        }
    }
}

enum RepositoryError: Error {
    case notFound
}
