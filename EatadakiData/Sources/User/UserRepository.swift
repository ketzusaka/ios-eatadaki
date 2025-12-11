import Foundation
import GRDB

public protocol UserRepository: AnyObject {
    func fetchUser() async throws -> User?
    func saveUser(_ user: User) async throws
    func clearUser() async throws
}

public protocol UserRepositoryProviding {
    var userRepository: UserRepository { get }
}

public actor RealUserRepository: UserRepository {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func fetchUser() async throws -> User? {
        try await db.read { db in
            try User.fetchOne(db)
        }
    }

    public func saveUser(_ user: User) async throws {
        try await db.write { db in
            // Delete existing user (should only be one)
            try User.deleteAll(db)
            // Insert new user
            try user.insert(db)
        }
    }

    public func clearUser() async throws {
        _ = try await db.write { db in
            try User.deleteAll(db)
        }
    }
}
