import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("RealUserRepository Tests")
struct UserRepositoryTests {
    @Test("Fetch user returns nil when no user exists")
    func testFetchUserReturnsNilWhenNoUserExists() async throws {
        let repository = try setupRepository()

        let user = try await repository.fetchUser()

        #expect(user == nil)
    }

    @Test("Fetch user returns user when user exists")
    func testFetchUserReturnsUserWhenUserExists() async throws {
        let repository = try setupRepository()
        let testUser = User(
            id: UUID(),
            email: "test@example.com",
            createdAt: .now
        )

        try await repository.saveUser(testUser)
        let fetchedUser = try await repository.fetchUser()

        let fetched = try #require(fetchedUser)
        #expect(fetched.id == testUser.id)
        #expect(fetched.email == testUser.email)
    }

    @Test("Save user successfully")
    func testSaveUser() async throws {
        let repository = try setupRepository()
        let testUser = User(
            id: UUID(),
            email: "test@example.com",
            createdAt: .now
        )

        try await repository.saveUser(testUser)

        let fetchedUser = try await repository.fetchUser()
        let fetched = try #require(fetchedUser)
        #expect(fetched.id == testUser.id)
        #expect(fetched.email == testUser.email)
    }

    @Test("Save user replaces existing user")
    func testSaveUserReplacesExistingUser() async throws {
        let repository = try setupRepository()
        let firstUser = User(
            id: UUID(),
            email: "first@example.com",
            createdAt: .now
        )
        let secondUser = User(
            id: UUID(),
            email: "second@example.com",
            createdAt: .now
        )

        try await repository.saveUser(firstUser)
        try await repository.saveUser(secondUser)

        let fetchedUser = try await repository.fetchUser()
        let fetched = try #require(fetchedUser)
        #expect(fetched.id == secondUser.id)
        #expect(fetched.email == secondUser.email)
        #expect(fetched.id != firstUser.id)
    }

    @Test("Save user ensures only one user exists")
    func testSaveUserEnsuresOnlyOneUserExists() async throws {
        let repository = try setupRepository()
        let user1 = User(
            id: UUID(),
            email: "user1@example.com",
            createdAt: .now
        )
        let user2 = User(
            id: UUID(),
            email: "user2@example.com",
            createdAt: .now
        )
        let user3 = User(
            id: UUID(),
            email: "user3@example.com",
            createdAt: .now
        )

        try await repository.saveUser(user1)
        try await repository.saveUser(user2)
        try await repository.saveUser(user3)

        // Verify only one user exists by checking we can only fetch one
        let fetchedUser = try await repository.fetchUser()
        let fetched = try #require(fetchedUser)
        #expect(fetched.id == user3.id)
        #expect(fetched.email == user3.email)
    }

    @Test("Clear user successfully")
    func testClearUser() async throws {
        let repository = try setupRepository()
        let testUser = User(
            id: UUID(),
            email: "test@example.com",
            createdAt: .now
        )

        try await repository.saveUser(testUser)
        try await repository.clearUser()

        let fetchedUser = try await repository.fetchUser()
        #expect(fetchedUser == nil)
    }

    @Test("Clear user when no user exists does not throw")
    func testClearUserWhenNoUserExists() async throws {
        let repository = try setupRepository()

        // Should not throw when clearing non-existent user
        try await repository.clearUser()

        let fetchedUser = try await repository.fetchUser()
        #expect(fetchedUser == nil)
    }

    @Test("Save and fetch user roundtrip")
    func testSaveAndFetchUserRoundtrip() async throws {
        let repository = try setupRepository()
        let testUser = User(
            id: UUID(),
            email: "roundtrip@example.com",
            createdAt: .now
        )

        try await repository.saveUser(testUser)
        let fetchedUser = try await repository.fetchUser()

        let fetched = try #require(fetchedUser)
        #expect(fetched.id == testUser.id)
        #expect(fetched.email == testUser.email)
        // Note: createdAt may have slight precision differences, so we verify it's close
        let timeDifference = abs(fetched.createdAt.timeIntervalSince(testUser.createdAt))
        #expect(timeDifference < 1.0) // Within 1 second
    }

    @Test("Observe user returns nil when no user exists")
    func testObserveUserReturnsNilWhenNoUserExists() async throws {
        let repository = try setupRepository()

        let observation = await repository.observeUser()
        var iterator = observation.makeAsyncIterator()

        // First value should be nil (unwrap outer optional first)
        let firstValueOptional = try await iterator.next()
        let firstValue = try #require(firstValueOptional)
        #expect(firstValue == nil)
    }

    @Test("Observe user returns user when user exists")
    func testObserveUserReturnsUserWhenUserExists() async throws {
        let repository = try setupRepository()
        let testUser = User(
            id: UUID(),
            email: "observe@example.com",
            createdAt: .now
        )

        try await repository.saveUser(testUser)

        let observation = await repository.observeUser()
        var iterator = observation.makeAsyncIterator()

        // Should get the user (iterator.next() returns User?? - unwrap both levels)
        let observedUserOptional = try await iterator.next()
        let observedUser = try #require(observedUserOptional)
        let user: User = try #require(observedUser)
        #expect(user.id == testUser.id)
        #expect(user.email == testUser.email)
    }

    @Test("Observe user emits updates when user is saved")
    func testObserveUserEmitsUpdatesWhenUserIsSaved() async throws {
        let repository = try setupRepository()

        let observation = await repository.observeUser()

        var iterator = observation.makeAsyncIterator()
        let initialUser = try await iterator.next()
        #expect(initialUser == .some(nil))

        let testUser = User(
            id: UUID(),
            email: "update@example.com",
            createdAt: Date(timeIntervalSince1970: 0)
        )
        try await repository.saveUser(testUser)

        let nextUser = try await iterator.next()
        let optionalUser = try #require(nextUser)
        let user: User = try #require(optionalUser)
        #expect(user == testUser)
    }

    @Test("Observe user emits nil when user is cleared")
    func testObserveUserEmitsNilWhenUserIsCleared() async throws {
        let repository = try setupRepository()
        let testUser = User(
            id: UUID(),
            email: "clear@example.com",
            createdAt: Date(timeIntervalSince1970: 0),
        )

        try await repository.saveUser(testUser)

        let observation = await repository.observeUser()

        var iterator = observation.makeAsyncIterator()
        let initialUser = try await iterator.next()
        #expect(initialUser == .some(testUser))

        // Clear the user
        try await repository.clearUser()

        let nextUser = try await iterator.next()
        let optionalUser = try #require(nextUser)
        #expect(optionalUser == nil)
    }

    // MARK: - Helpers

    private func createInMemoryDatabase() throws -> DatabaseQueue {
        try DatabaseQueue()
    }

    private func setupRepository() throws -> RealUserRepository {
        let db = try createInMemoryDatabase()
        let migrator = UserDatabaseMigrator(db: db)
        try migrator.migrate()
        return RealUserRepository(db: db)
    }
}
