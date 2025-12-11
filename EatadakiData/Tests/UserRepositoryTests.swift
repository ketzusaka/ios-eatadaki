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
