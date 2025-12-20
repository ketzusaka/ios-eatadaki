import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("RealExperiencesRepository Tests")
struct RealExperiencesRepositoryTests {
    let repository: RealExperiencesRepository
    let db: DatabaseQueue

    init() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()
        self.db = db
        self.repository = RealExperiencesRepository(db: db)
    }

    @Test("Create experience successfully")
    func testCreateExperience() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(spotId: spot.id, rating: 5, note: "Great experience!")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: "A test experience",
            rating: rating,
        )

        #expect(experience.spotId == spot.id)
        #expect(experience.name == "Test Experience")
        #expect(experience.description == "A test experience")
    }

    @Test("Create experience without description")
    func testCreateExperienceWithoutDescription() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(spotId: spot.id, rating: 4)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )

        #expect(experience.spotId == spot.id)
        #expect(experience.name == "Test Experience")
        #expect(experience.description == nil)
    }

    @Test("Create experience creates rating in database")
    func testCreateExperienceCreatesRating() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(spotId: spot.id, rating: 5, note: "Amazing!")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )

        // Verify rating was created in database
        let fetchedRating = try await db.read { database in
            try ExperienceRatingRecord.filter(Column("experienceId") == experience.id).fetchOne(database)
        }
        let ratingRecord = try #require(fetchedRating)
        #expect(ratingRecord.experienceId == experience.id)
        #expect(ratingRecord.rating == 5)
        #expect(ratingRecord.notes == "Amazing!")
    }

    @Test("Create experience throws spotNotFound when spot does not exist")
    func testCreateExperienceThrowsSpotNotFound() async throws {
        let nonExistentSpotId = UUID()
        let rating = CreateRating(spotId: nonExistentSpotId, rating: 5)

        await #expect(throws: ExperiencesRepositoryError.spotNotFound) {
            try await repository.createExperience(
                spotId: nonExistentSpotId,
                name: "Test Experience",
                description: nil,
                rating: rating,
            )
        }
    }

    @Test("Create experience throws invalidRating when rating spotId does not match")
    func testCreateExperienceThrowsInvalidRating() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let differentSpotId = UUID()
        let rating = CreateRating(spotId: differentSpotId, rating: 5)

        await #expect(throws: ExperiencesRepositoryError.invalidRating) {
            try await repository.createExperience(
                spotId: spot.id,
                name: "Test Experience",
                description: nil,
                rating: rating,
            )
        }
    }

    @Test("Create experience with rating without note")
    func testCreateExperienceWithRatingWithoutNote() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(spotId: spot.id, rating: 3, note: nil)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )

        // Verify rating was created without note
        let fetchedRating = try await db.read { database in
            try ExperienceRatingRecord.filter(Column("experienceId") == experience.id).fetchOne(database)
        }
        let ratingRecord = try #require(fetchedRating)
        #expect(ratingRecord.rating == 3)
        #expect(ratingRecord.notes == nil)
    }

    @Test("Create experience generates unique IDs")
    func testCreateExperienceGeneratesUniqueIDs() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating1 = CreateRating(spotId: spot.id, rating: 5)
        let rating2 = CreateRating(spotId: spot.id, rating: 4)

        let experience1 = try await repository.createExperience(
            spotId: spot.id,
            name: "Experience 1",
            description: nil,
            rating: rating1,
        )
        let experience2 = try await repository.createExperience(
            spotId: spot.id,
            name: "Experience 2",
            description: nil,
            rating: rating2,
        )

        #expect(experience1.id != experience2.id)
    }

    @Test("Create experience sets createdAt timestamp")
    func testCreateExperienceSetsCreatedAt() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let beforeCreation = Date()
        let rating = CreateRating(spotId: spot.id, rating: 5)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )
        let afterCreation = Date()

        #expect(experience.createdAt >= beforeCreation)
        #expect(experience.createdAt <= afterCreation)
    }

    @Test("Create experience creates both experience and rating in transaction")
    func testCreateExperienceCreatesBothInTransaction() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(spotId: spot.id, rating: 5, note: "Test note")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: "Test description",
            rating: rating,
        )

        // Verify both records exist
        let fetchedExperience = try await db.read { database in
            try ExperienceRecord.fetchOne(database, key: experience.id)
        }
        let fetchedRating = try await db.read { database in
            try ExperienceRatingRecord.filter(Column("experienceId") == experience.id).fetchOne(database)
        }

        let exp = try #require(fetchedExperience)
        let rat = try #require(fetchedRating)

        #expect(exp.id == experience.id)
        #expect(exp.name == "Test Experience")
        #expect(exp.description == "Test description")
        #expect(rat.experienceId == experience.id)
        #expect(rat.rating == 5)
        #expect(rat.notes == "Test note")
    }
}
