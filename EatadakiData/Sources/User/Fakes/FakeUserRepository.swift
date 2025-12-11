#if DEBUG
import Foundation

public class FakeUserRepository: UserRepository {
    public init(_ configure: (FakeUserRepository) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invokedCountFetchUser: Int = 0
    public var stubFetchUser: () async throws(UserRepositoryError) -> User? = {
        nil
    }

    public func fetchUser() async throws(UserRepositoryError) -> User? {
        invokedCountFetchUser += 1
        return try await stubFetchUser()
    }

    public private(set) var invocationsSaveUser: [User] = []
    public var stubSaveUser: (User) async throws(UserRepositoryError) -> Void = { _ in }

    public func saveUser(_ user: User) async throws(UserRepositoryError) {
        invocationsSaveUser.append(user)
        try await stubSaveUser(user)
    }

    public private(set) var invokedCountClearUser: Int = 0
    public var stubClearUser: () async throws(UserRepositoryError) -> Void = { }

    public func clearUser() async throws(UserRepositoryError) {
        invokedCountClearUser += 1
        try await stubClearUser()
    }
}
#endif
