#if DEBUG
import Foundation

public class FakeUserRepository: UserRepository {
    
    public init(_ configure: (FakeUserRepository) -> Void = { _ in }) {
        configure(self)
    }
    
    public private(set) var invokedCountFetchUser: Int = 0
    public var stubFetchUser: () async throws -> User? = {
        nil
    }
    
    public func fetchUser() async throws -> User? {
        invokedCountFetchUser += 1
        return try await stubFetchUser()
    }
    
    public private(set) var invocationsSaveUser: [User] = []
    public var stubSaveUser: (User) async throws -> Void = { _ in }
    
    public func saveUser(_ user: User) async throws {
        invocationsSaveUser.append(user)
        try await stubSaveUser(user)
    }
    
    public private(set) var invokedCountClearUser: Int = 0
    public var stubClearUser: () async throws -> Void = { }
    
    public func clearUser() async throws {
        invokedCountClearUser += 1
        try await stubClearUser()
    }
}
#endif
