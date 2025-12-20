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
        #expect(experience.rating == 5)
        #expect(experience.ratingNote == "Great experience!")
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
        #expect(experience.rating == 4)
        #expect(experience.ratingNote == nil)
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
        
        // Verify cached rating fields on experience
        #expect(experience.rating == 5)
        #expect(experience.ratingNote == "Amazing!")
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
        
        // Verify cached rating fields on experience
        #expect(experience.rating == 3)
        #expect(experience.ratingNote == nil)
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
        #expect(exp.rating == 5)
        #expect(exp.ratingNote == "Test note")
        #expect(rat.experienceId == experience.id)
        #expect(rat.rating == 5)
        #expect(rat.notes == "Test note")
    }
    
    @Test("Create experience without rating has nil cached rating fields")
    func testCreateExperienceWithoutRating() async throws {
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

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: "A test experience",
            rating: nil,
        )

        #expect(experience.rating == nil)
        #expect(experience.ratingNote == nil)
    }

    // MARK: - Fetch Experiences Tests

    @Test("Fetch experiences returns empty array when no experiences exist")
    func testFetchExperiencesEmpty() async throws {
        let experiences = try await repository.fetchExperiences()

        #expect(experiences.isEmpty == true)
    }

    @Test("Fetch experiences returns single experience with spot")
    func testFetchExperiencesSingle() async throws {
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

        let rating = CreateRating(spotId: spot.id, rating: 5)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: "A test experience",
            rating: rating,
        )

        let experiences = try await repository.fetchExperiences()

        #expect(experiences.count == 1)
        let experienceInfo = try #require(experiences.first)
        #expect(experienceInfo.experience.id == experience.id)
        #expect(experienceInfo.experience.name == "Test Experience")
        #expect(experienceInfo.experience.description == "A test experience")
        #expect(experienceInfo.experience.spotId == spot.id)
        #expect(experienceInfo.spot.id == spot.id)
        #expect(experienceInfo.spot.name == spot.name)
    }

    @Test("Fetch experiences returns multiple experiences from same spot")
    func testFetchExperiencesMultipleFromSameSpot() async throws {
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
            description: "Second experience",
            rating: rating2,
        )

        let experiences = try await repository.fetchExperiences()

        #expect(experiences.count == 2)
        let experienceIds = Set(experiences.map(\.experience.id))
        #expect(experienceIds.contains(experience1.id))
        #expect(experienceIds.contains(experience2.id))
        
        // Verify all experiences have the correct spot relationship
        for experienceInfo in experiences {
            #expect(experienceInfo.experience.spotId == spot.id)
            #expect(experienceInfo.spot.id == spot.id)
            #expect(experienceInfo.spot.name == spot.name)
        }
    }

    @Test("Fetch experiences returns multiple experiences from different spots")
    func testFetchExperiencesMultipleFromDifferentSpots() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Spot 1",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Spot 2",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        try await db.write { database in
            try spot1.insert(database)
            try spot2.insert(database)
        }

        let rating1 = CreateRating(spotId: spot1.id, rating: 5)
        let rating2 = CreateRating(spotId: spot2.id, rating: 4)
        let experience1 = try await repository.createExperience(
            spotId: spot1.id,
            name: "Experience 1",
            description: nil,
            rating: rating1,
        )
        let experience2 = try await repository.createExperience(
            spotId: spot2.id,
            name: "Experience 2",
            description: nil,
            rating: rating2,
        )

        let experiences = try await repository.fetchExperiences()

        #expect(experiences.count == 2)
        let experienceIds = Set(experiences.map(\.experience.id))
        #expect(experienceIds.contains(experience1.id))
        #expect(experienceIds.contains(experience2.id))
        
        // Verify spot relationships are correct
        let experience1Info = experiences.first { $0.experience.id == experience1.id }
        let experience2Info = experiences.first { $0.experience.id == experience2.id }
        let exp1Info = try #require(experience1Info)
        let exp2Info = try #require(experience2Info)
        
        #expect(exp1Info.experience.spotId == spot1.id)
        #expect(exp1Info.spot.id == spot1.id)
        #expect(exp1Info.spot.name == spot1.name)
        
        #expect(exp2Info.experience.spotId == spot2.id)
        #expect(exp2Info.spot.id == spot2.id)
        #expect(exp2Info.spot.name == spot2.name)
    }

    @Test("Fetch experiences with default request parameter")
    func testFetchExperiencesWithDefaultRequest() async throws {
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

        let rating = CreateRating(spotId: spot.id, rating: 5)
        _ = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )

        let experiences = try await repository.fetchExperiences(request: .default)

        #expect(experiences.count == 1)
    }

    // MARK: - Fetch Experience By ID Tests

    @Test("Fetch experience by ID successfully")
    func testFetchExperienceByID() async throws {
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

        let fetchedExperience = try await repository.fetchExperience(withID: experience.id)

        #expect(fetchedExperience.experience.id == experience.id)
        #expect(fetchedExperience.experience.name == "Test Experience")
        #expect(fetchedExperience.experience.description == "A test experience")
        #expect(fetchedExperience.experience.spotId == spot.id)
        #expect(fetchedExperience.spot.id == spot.id)
        #expect(fetchedExperience.spot.name == spot.name)
        #expect(fetchedExperience.ratingHistory.count == 1)
        let ratingRecord = try #require(fetchedExperience.ratingHistory.first)
        #expect(ratingRecord.rating == 5)
        #expect(ratingRecord.notes == "Great experience!")
        #expect(ratingRecord.experienceId == experience.id)
    }

    @Test("Fetch experience by ID throws experienceNotFound when experience does not exist")
    func testFetchExperienceByIDNotFound() async throws {
        let nonExistentID = UUID()

        await #expect(throws: ExperiencesRepositoryError.experienceNotFound) {
            try await repository.fetchExperience(withID: nonExistentID)
        }
    }

    @Test("Fetch experience by ID returns empty rating history when no ratings exist")
    func testFetchExperienceByIDWithNoRatingHistory() async throws {
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

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let fetchedExperience = try await repository.fetchExperience(withID: experience.id)

        #expect(fetchedExperience.experience.id == experience.id)
        #expect(fetchedExperience.ratingHistory.isEmpty == true)
    }

    @Test("Fetch experience by ID returns multiple ratings in history")
    func testFetchExperienceByIDWithMultipleRatings() async throws {
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

        let rating1 = CreateRating(spotId: spot.id, rating: 5, note: "First rating")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating1,
        )

        // Add additional ratings directly to the database
        let rating2 = ExperienceRatingRecord(
            id: UUID(),
            experienceId: experience.id,
            rating: 4,
            notes: "Second rating",
            createdAt: .now,
        )
        let rating3 = ExperienceRatingRecord(
            id: UUID(),
            experienceId: experience.id,
            rating: 5,
            notes: "Third rating",
            createdAt: .now,
        )
        try await db.write { database in
            try rating2.insert(database)
            try rating3.insert(database)
        }

        let fetchedExperience = try await repository.fetchExperience(withID: experience.id)

        #expect(fetchedExperience.experience.id == experience.id)
        #expect(fetchedExperience.ratingHistory.count == 3)
        let ratingIds = Set(fetchedExperience.ratingHistory.map(\.id))
        #expect(ratingIds.contains(rating2.id))
        #expect(ratingIds.contains(rating3.id))
        
        // Verify all ratings belong to this experience
        for ratingRecord in fetchedExperience.ratingHistory {
            #expect(ratingRecord.experienceId == experience.id)
        }
    }

    @Test("Fetch experience by ID includes spot data")
    func testFetchExperienceByIDIncludesSpotData() async throws {
        let spot = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(spotId: spot.id, rating: 5)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )

        let fetchedExperience = try await repository.fetchExperience(withID: experience.id)

        #expect(fetchedExperience.spot.id == spot.id)
        #expect(fetchedExperience.spot.name == spot.name)
        #expect(fetchedExperience.spot.latitude == spot.latitude)
        #expect(fetchedExperience.spot.longitude == spot.longitude)
        #expect(fetchedExperience.experience.spotId == spot.id)
    }
}
