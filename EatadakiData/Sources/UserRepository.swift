import Foundation
import GRDB
import Pour

public protocol UserRepository: AnyObject {
    func fetchUser() async throws -> User?
    func saveUser(_ user: User) async throws
    func clearUser() async throws
}

public protocol UserRepositoryDependencies {
    var userDataService: UserDataService { get }
}

public protocol UserRepositoryProviding {
    var userRepository: UserRepository { get }
}

public extension Pouring where Self: UserRepositoryDependencies {
    var userRepository: UserRepository {
        shared {
            RealUserRepository(service: userDataService)
        }
    }
}

public actor RealUserRepository: UserRepository {

    private let service: UserDataService

    public init(service: UserDataService) {
        self.service = service
    }

    public func fetchUser() async throws -> User? {
        try await service.db.read { db in
            try User.fetchOne(db)
        }
    }

    public func saveUser(_ user: User) async throws {
        try await service.db.write { db in
            // Delete existing user (should only be one)
            try User.deleteAll(db)
            // Insert new user
            try user.insert(db)
        }
    }

    public func clearUser() async throws {
        _ = try await service.db.write { db in
            try User.deleteAll(db)
        }
    }

}
