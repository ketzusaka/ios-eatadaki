import Foundation
import GRDB
import Pour

public protocol SpotsRepository: AnyObject {
    func fetchSpot(withID id: UUID) async throws -> Spot
    func fetchSpots() async throws -> [Spot]
    func create(spot: Spot) async throws -> Spot
}

public protocol SpotsRepositoryDependencies {
    var experiencesDataService: ExperiencesDataService { get }
}

public extension Pouring where Self: SpotsRepositoryDependencies {
    var spotsRepository: SpotsRepository {
        shared { 
            RealSpotsRepository(service: experiencesDataService)
        }
    }
}

public protocol SpotsRepositoryProviding {
    var spotsRepository: SpotsRepository { get }
}

public actor RealSpotsRepository: SpotsRepository {
    private let service: ExperiencesDataService

    public init(service: ExperiencesDataService) {
        self.service = service
    }

    public func fetchSpot(withID id: UUID) async throws -> Spot {
        do {
            return try await service.db.read { db in
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
            return try await service.db.read { db in
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
            return try await service.db.write { db in
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
