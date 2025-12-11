import Foundation
import GRDB

public enum UserRepositoryError: Error {
    case databaseError(String)
}

public protocol UserRepository: AnyObject {
    func fetchUser() async throws(UserRepositoryError) -> User?
    func saveUser(_ user: User) async throws(UserRepositoryError)
    func clearUser() async throws(UserRepositoryError)
}

public protocol UserRepositoryProviding {
    var userRepository: UserRepository { get }
}

public actor RealUserRepository: UserRepository {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func fetchUser() async throws(UserRepositoryError) -> User? {
        do {
            return try await db.read { db in
                try User.fetchOne(db)
            }
        } catch let error as UserRepositoryError {
            throw error
        } catch {
            throw UserRepositoryError.databaseError(error.localizedDescription)
        }
    }
    
    public func observeUser() -> any AsyncSequence<User?, Error> {
        ValueObservation.tracking { db in
            try User.fetchOne(db)
        }
        .values(in: db)
    }

    public func saveUser(_ user: User) async throws(UserRepositoryError) {
        do {
            return try await db.write { db in
                // Delete existing user (should only be one)
                try User.deleteAll(db)
                // Insert new user
                try user.insert(db)
            }
        } catch let error as UserRepositoryError {
            throw error
        } catch {
            throw UserRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func clearUser() async throws(UserRepositoryError) {
        do {
            _ = try await db.write { db in
                try User.deleteAll(db)
            }
        } catch let error as UserRepositoryError {
            throw error
        } catch {
            throw UserRepositoryError.databaseError(error.localizedDescription)
        }
    }
}
