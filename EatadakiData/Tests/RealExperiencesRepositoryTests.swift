import EatadakiData
import EatadakiSpotsKit
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5, note: "Great experience!")
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 4)
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5, note: "Amazing!")
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
        let rating = CreateRating(rating: 5)

        await #expect(throws: ExperiencesRepositoryError.spotNotFound) {
            try await repository.createExperience(
                spotId: nonExistentSpotId,
                name: "Test Experience",
                description: nil,
                rating: rating,
            )
        }
    }

    @Test("Create experience with rating without note")
    func testCreateExperienceWithRatingWithoutNote() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 3, note: nil)
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating1 = CreateRating(rating: 5)
        let rating2 = CreateRating(rating: 4)

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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let beforeCreation = Date()
        let rating = CreateRating(rating: 5)
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5, note: "Test note")
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
        let spot = SpotRecord.peacePagoda
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

    // MARK: - Create Experience Rating Tests

    @Test("Create experience rating successfully")
    func testCreateExperienceRating() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let rating = CreateRating(rating: 5, note: "Great rating!")
        let ratingRecord = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating,
        )

        #expect(ratingRecord.experienceId == experience.id)
        #expect(ratingRecord.rating == 5)
        #expect(ratingRecord.notes == "Great rating!")
    }

    @Test("Create experience rating without note")
    func testCreateExperienceRatingWithoutNote() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let rating = CreateRating(rating: 4)
        let ratingRecord = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating,
        )

        #expect(ratingRecord.experienceId == experience.id)
        #expect(ratingRecord.rating == 4)
        #expect(ratingRecord.notes == nil)
    }

    @Test("Create experience rating throws experienceNotFound when experience does not exist")
    func testCreateExperienceRatingThrowsExperienceNotFound() async throws {
        let nonExistentExperienceId = UUID()
        let rating = CreateRating(rating: 5)

        await #expect(throws: ExperiencesRepositoryError.experienceNotFound) {
            try await repository.createExperienceRating(
                experienceId: nonExistentExperienceId,
                rating: rating,
            )
        }
    }

    @Test("Create experience rating generates unique IDs")
    func testCreateExperienceRatingGeneratesUniqueIDs() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let rating1 = CreateRating(rating: 5)
        let rating2 = CreateRating(rating: 4)

        let ratingRecord1 = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating1,
        )
        let ratingRecord2 = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating2,
        )

        #expect(ratingRecord1.id != ratingRecord2.id)
    }

    @Test("Create experience rating sets createdAt timestamp")
    func testCreateExperienceRatingSetsCreatedAt() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let beforeCreation = Date()
        let rating = CreateRating(rating: 5)
        let ratingRecord = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating,
        )
        let afterCreation = Date()

        #expect(ratingRecord.createdAt >= beforeCreation)
        #expect(ratingRecord.createdAt <= afterCreation)
    }

    @Test("Create experience rating persists to database")
    func testCreateExperienceRatingPersistsToDatabase() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let rating = CreateRating(rating: 5, note: "Test note")
        let ratingRecord = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating,
        )

        // Verify rating was persisted in database
        let fetchedRating = try await db.read { database in
            try ExperienceRatingRecord.fetchOne(database, key: ratingRecord.id)
        }
        let fetched = try #require(fetchedRating)
        #expect(fetched.id == ratingRecord.id)
        #expect(fetched.experienceId == experience.id)
        #expect(fetched.rating == 5)
        #expect(fetched.notes == "Test note")
    }

    @Test("Create experience rating allows multiple ratings for same experience")
    func testCreateExperienceRatingMultipleRatings() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let rating1 = CreateRating(rating: 5, note: "First rating")
        let rating2 = CreateRating(rating: 4, note: "Second rating")
        let rating3 = CreateRating(rating: 5, note: "Third rating")

        let ratingRecord1 = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating1,
        )
        let ratingRecord2 = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating2,
        )
        let ratingRecord3 = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating3,
        )

        // Verify all ratings were created
        let allRatings = try await db.read { database in
            try ExperienceRatingRecord.filter(Column("experienceId") == experience.id).fetchAll(database)
        }
        #expect(allRatings.count == 3)
        let ratingIds = Set(allRatings.map(\.id))
        #expect(ratingIds.contains(ratingRecord1.id))
        #expect(ratingIds.contains(ratingRecord2.id))
        #expect(ratingIds.contains(ratingRecord3.id))
    }

    @Test("Create experience rating updates cached rating fields on experience")
    func testCreateExperienceRatingUpdatesCachedRatingFields() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        // Create experience with an initial rating
        let initialRating = CreateRating(rating: 3, note: "Initial rating")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: initialRating,
        )

        // Verify initial cached rating
        #expect(experience.rating == 3)
        #expect(experience.ratingNote == "Initial rating")

        // Create a new rating which should update the cached fields
        let newRating = CreateRating(rating: 5, note: "Updated rating")
        _ = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: newRating,
        )

        // Verify cached rating fields were updated
        let fetchedExperience = try await db.read { database in
            try ExperienceRecord.fetchOne(database, key: experience.id)
        }
        let exp = try #require(fetchedExperience)
        #expect(exp.rating == 5)
        #expect(exp.ratingNote == "Updated rating")
    }

    @Test("Create experience rating updates cached rating when experience had no previous rating")
    func testCreateExperienceRatingUpdatesCachedRatingFromNil() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        // Create experience without a rating
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        // Verify initial cached rating is nil
        #expect(experience.rating == nil)
        #expect(experience.ratingNote == nil)

        // Create a rating which should set the cached fields
        let rating = CreateRating(rating: 4, note: "First rating")
        _ = try await repository.createExperienceRating(
            experienceId: experience.id,
            rating: rating,
        )

        // Verify cached rating fields were set
        let fetchedExperience = try await db.read { database in
            try ExperienceRecord.fetchOne(database, key: experience.id)
        }
        let exp = try #require(fetchedExperience)
        #expect(exp.rating == 4)
        #expect(exp.ratingNote == "First rating")
    }

    // MARK: - Fetch Experiences Tests

    @Test("Fetch experiences returns empty array when no experiences exist")
    func testFetchExperiencesEmpty() async throws {
        let experiences = try await repository.fetchExperiences()

        #expect(experiences.isEmpty == true)
    }

    @Test("Fetch experiences returns single experience with spot")
    func testFetchExperiencesSingle() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5)
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating1 = CreateRating(rating: 5)
        let rating2 = CreateRating(rating: 4)
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
        let spot1 = SpotRecord.peacePagoda
        let spot2 = SpotRecord.kinokuniya
        try await db.write { database in
            try spot1.insert(database)
            try spot2.insert(database)
        }

        let rating1 = CreateRating(rating: 5)
        let rating2 = CreateRating(rating: 4)
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5)
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5, note: "Great experience!")
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
        let spot = SpotRecord.peacePagoda
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating1 = CreateRating(rating: 5, note: "First rating")
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
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5)
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

    // MARK: - Observe Experience Tests

    @Test("Observe experience emits initial experience when it exists")
    func testObserveExperienceEmitsInitialExperience() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5, note: "Great!")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: "A test experience",
            rating: rating,
        )

        let observation = await repository.observeExperience(withID: experience.id)
        var iterator = observation.makeAsyncIterator()

        let observedExperience = try await iterator.next()
        let exp = try #require(observedExperience)
        #expect(exp.experience.id == experience.id)
        #expect(exp.experience.name == "Test Experience")
        #expect(exp.spot.id == spot.id)
        #expect(exp.ratingHistory.count == 1)
    }

    @Test("Observe experience throws experienceNotFound when experience does not exist")
    func testObserveExperienceThrowsNotFound() async throws {
        let nonExistentID = UUID()
        let observation = await repository.observeExperience(withID: nonExistentID)
        var iterator = observation.makeAsyncIterator()

        await #expect(throws: ExperiencesRepositoryError.experienceNotFound) {
            try await iterator.next()
        }
    }

    @Test("Observe experience emits updates when experience changes")
    func testObserveExperienceEmitsOnExperienceUpdate() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Original Name",
            description: nil,
            rating: rating,
        )

        let observation = await repository.observeExperience(withID: experience.id)
        var iterator = observation.makeAsyncIterator()

        // Get initial value
        let initialExperience = try await iterator.next()
        let initial = try #require(initialExperience)
        #expect(initial.experience.name == "Original Name")

        // Update the experience name directly in database
        try await db.write { database in
            var updatedExperience = experience
            updatedExperience.name = "Updated Name"
            try updatedExperience.update(database)
        }

        // Should emit updated value
        let updatedExperience = try await iterator.next()
        let updated = try #require(updatedExperience)
        #expect(updated.experience.name == "Updated Name")
        #expect(updated.experience.id == experience.id)
    }

    @Test("Observe experience emits updates when rating is added")
    func testObserveExperienceEmitsOnRatingAdded() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating1 = CreateRating(rating: 5, note: "First rating")
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating1,
        )

        let observation = await repository.observeExperience(withID: experience.id)
        var iterator = observation.makeAsyncIterator()

        // Get initial value with one rating
        let initialExperience = try await iterator.next()
        let initial = try #require(initialExperience)
        #expect(initial.ratingHistory.count == 1)

        // Add another rating
        let rating2 = ExperienceRatingRecord(
            id: UUID(),
            experienceId: experience.id,
            rating: 4,
            notes: "Second rating",
            createdAt: .now,
        )
        try await db.write { database in
            try rating2.insert(database)
        }

        // Should emit updated value with two ratings
        let updatedExperience = try await iterator.next()
        let updated = try #require(updatedExperience)
        #expect(updated.ratingHistory.count == 2)
        let ratingIds = Set(updated.ratingHistory.map(\.id))
        #expect(ratingIds.contains(rating2.id))
    }

    @Test("Observe experience includes spot data")
    func testObserveExperienceIncludesSpotData() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let rating = CreateRating(rating: 5)
        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: rating,
        )

        let observation = await repository.observeExperience(withID: experience.id)
        var iterator = observation.makeAsyncIterator()

        let observedExperience = try await iterator.next()
        let exp = try #require(observedExperience)
        #expect(exp.spot.id == spot.id)
        #expect(exp.spot.name == spot.name)
        #expect(exp.spot.latitude == spot.latitude)
        #expect(exp.spot.longitude == spot.longitude)
        #expect(exp.experience.spotId == spot.id)
    }

    @Test("Observe experience returns empty rating history when no ratings exist")
    func testObserveExperienceWithNoRatingHistory() async throws {
        let spot = SpotRecord.peacePagoda
        try await db.write { database in
            try spot.insert(database)
        }

        let experience = try await repository.createExperience(
            spotId: spot.id,
            name: "Test Experience",
            description: nil,
            rating: nil,
        )

        let observation = await repository.observeExperience(withID: experience.id)
        var iterator = observation.makeAsyncIterator()

        let observedExperience = try await iterator.next()
        let exp = try #require(observedExperience)
        #expect(exp.ratingHistory.isEmpty == true)
    }
}
