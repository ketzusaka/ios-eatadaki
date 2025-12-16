import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("RealSpotsRepository Tests")
struct RealSpotsRepositoryTests {
    let repository: RealSpotsRepository

    init() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()
        self.repository = RealSpotsRepository(db: db)
    }

    @Test("Create spot successfully")
    func testCreateSpot() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "test-mapkit-id",
            remoteId: "test-remote-id",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let createdSpot = try await repository.create(spot: testSpot)

        #expect(createdSpot.id == testSpot.id)
        #expect(createdSpot.name == testSpot.name)
        #expect(createdSpot.mapkitId == testSpot.mapkitId)
        #expect(createdSpot.remoteId == testSpot.remoteId)
    }

    @Test("Fetch spot by ID successfully")
    func testFetchSpotByID() async throws {
        let testSpot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: testSpot.id)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by ID throws notFound when spot does not exist")
    func testFetchSpotByIDNotFound() async throws {
        let nonExistentID = UUID()

        await #expect(throws: SpotsRepositoryError.spotNotFound) {
            try await repository.fetchSpot(withID: nonExistentID)
        }
    }

    @Test("Fetch all spots returns empty array when no spots exist")
    func testFetchSpotsEmpty() async throws {
        let spots = try await repository.fetchSpots()

        #expect(spots.isEmpty == true)
    }

    @Test("Fetch all spots returns single spot")
    func testFetchSpotsSingle() async throws {
        let testSpot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spots = try await repository.fetchSpots()

        #expect(spots.count == 1)
        #expect(spots.first?.id == testSpot.id)
        #expect(spots.first?.name == testSpot.name)
    }

    @Test("Fetch all spots returns multiple spots in correct order")
    func testFetchSpotsMultiple() async throws {
        let spot1 = Spot(
            id: UUID(),
            name: "Spot 1",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = Spot(
            id: UUID(),
            name: "Spot 2",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spot3 = Spot(
            id: UUID(),
            name: "Spot 3",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)
        _ = try await repository.create(spot: spot3)

        let spots = try await repository.fetchSpots()

        #expect(spots.count == 3)
        let spotIds = Set(spots.map { $0.id })
        #expect(spotIds.contains(spot1.id))
        #expect(spotIds.contains(spot2.id))
        #expect(spotIds.contains(spot3.id))
    }

    @Test("Create spot with all optional fields")
    func testCreateSpotWithOptionalFields() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Full Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let createdSpot = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: createdSpot.id)

        #expect(fetchedSpot.mapkitId == "mapkit-123")
        #expect(fetchedSpot.remoteId == "remote-456")
    }

    @Test("Create spot without optional fields")
    func testCreateSpotWithoutOptionalFields() async throws {
        let testSpot = Spot(
            id: UUID(),
            name: "Minimal Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now
        )

        let createdSpot = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: createdSpot.id)

        #expect(fetchedSpot.mapkitId == nil)
        #expect(fetchedSpot.remoteId == nil)
        #expect(fetchedSpot.name == "Minimal Spot")
    }

    // MARK: - fetchSpot(withIDs:) Tests

    @Test("Fetch spot by SpotIDs with UUID successfully")
    func testFetchSpotBySpotIDsWithUUID() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(id: testSpot.id)
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with mapkitId successfully")
    func testFetchSpotBySpotIDsWithMapkitId() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(mapkitId: testSpot.mapkitId)
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.mapkitId == testSpot.mapkitId)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with remoteId successfully")
    func testFetchSpotBySpotIDsWithRemoteId() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(remoteId: testSpot.remoteId)
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.remoteId == testSpot.remoteId)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with UUID and mapkitId matches by UUID")
    func testFetchSpotBySpotIDsWithUUIDAndMapkitId() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(id: testSpot.id, mapkitId: "different-mapkit-id")
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with UUID and mapkitId matches by mapkitId")
    func testFetchSpotBySpotIDsWithUUIDAndMapkitIdMatchesMapkitId() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(id: UUID(), mapkitId: testSpot.mapkitId)
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.mapkitId == testSpot.mapkitId)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with all IDs provided")
    func testFetchSpotBySpotIDsWithAllIDs() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(
            id: testSpot.id,
            mapkitId: testSpot.mapkitId,
            remoteId: testSpot.remoteId,
        )
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.mapkitId == testSpot.mapkitId)
        #expect(fetchedSpot.remoteId == testSpot.remoteId)
        #expect(fetchedSpot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs throws noIDsProvided when all IDs are nil")
    func testFetchSpotBySpotIDsThrowsNoIDsProvided() async throws {
        let spotIDs = SpotIDs()

        await #expect(throws: SpotsRepositoryError.noIDsProvided) {
            try await repository.fetchSpot(withIDs: spotIDs)
        }
    }

    @Test("Fetch spot by SpotIDs throws spotNotFound when no spot matches")
    func testFetchSpotBySpotIDsThrowsNotFound() async throws {
        let spotIDs = SpotIDs(id: UUID(), mapkitId: "non-existent", remoteId: "non-existent")

        await #expect(throws: SpotsRepositoryError.spotNotFound) {
            try await repository.fetchSpot(withIDs: spotIDs)
        }
    }

    @Test("Fetch spot by SpotIDs matches spot with only mapkitId when searching by mapkitId")
    func testFetchSpotBySpotIDsMatchesByMapkitIdOnly() async throws {
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(mapkitId: "mapkit-123")
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.mapkitId == "mapkit-123")
    }

    @Test("Fetch spot by SpotIDs matches spot with only remoteId when searching by remoteId")
    func testFetchSpotBySpotIDsMatchesByRemoteIdOnly() async throws {
        let testSpot = Spot(
            id: UUID(),
            remoteId: "remote-456",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spotIDs = SpotIDs(remoteId: "remote-456")
        let fetchedSpot = try await repository.fetchSpot(withIDs: spotIDs)

        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.remoteId == "remote-456")
    }

    // MARK: - save(spot:) Tests

    @Test("Save creates new spot when spot does not exist")
    func testSaveCreatesNewSpot() async throws {
        let newSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "New Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        let savedSpot = try await repository.save(spot: newSpot)

        #expect(savedSpot.id == newSpot.id)
        #expect(savedSpot.name == newSpot.name)
        #expect(savedSpot.latitude == newSpot.latitude)
        #expect(savedSpot.longitude == newSpot.longitude)
        #expect(savedSpot.remoteId == newSpot.remoteId)

        // Verify it was actually created
        let fetchedSpot = try await repository.fetchSpot(withID: savedSpot.id)
        #expect(fetchedSpot.id == savedSpot.id)
        #expect(fetchedSpot.name == savedSpot.name)
    }

    @Test("Save updates existing spot when found by id")
    func testSaveUpdatesExistingSpotByID() async throws {
        let originalSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = Spot(
            id: originalSpot.id,
            mapkitId: originalSpot.mapkitId,
            remoteId: "updated-remote-id",
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: originalSpot.createdAt,
        )

        let savedSpot = try await repository.save(spot: updatedSpot)

        #expect(savedSpot.id == originalSpot.id)
        #expect(savedSpot.name == "Updated Name")
        #expect(savedSpot.latitude == 40.7128)
        #expect(savedSpot.longitude == -74.0060)
        #expect(savedSpot.remoteId == "updated-remote-id")
        #expect(savedSpot.mapkitId == originalSpot.mapkitId)
        #expect(savedSpot.createdAt == originalSpot.createdAt)
    }

    @Test("Save updates existing spot when found by mapkitId")
    func testSaveUpdatesExistingSpotByMapkitId() async throws {
        let originalSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = Spot(
            id: UUID(), // Different ID
            mapkitId: "mapkit-123", // Same mapkitId
            remoteId: "updated-remote-id",
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: .now,
        )

        let savedSpot = try await repository.save(spot: updatedSpot)

        // Should update the original spot, not create a new one
        #expect(savedSpot.id == originalSpot.id)
        #expect(savedSpot.name == "Updated Name")
        #expect(savedSpot.latitude == 40.7128)
        #expect(savedSpot.longitude == -74.0060)
        #expect(savedSpot.remoteId == "updated-remote-id")
        #expect(savedSpot.mapkitId == "mapkit-123")
    }

    @Test("Save updates existing spot when found by remoteId")
    func testSaveUpdatesExistingSpotByRemoteId() async throws {
        let originalSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = Spot(
            id: UUID(), // Different ID
            mapkitId: nil, // No mapkitId
            remoteId: "remote-456", // Same remoteId
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: .now,
        )

        let savedSpot = try await repository.save(spot: updatedSpot)

        // Should update the original spot, not create a new one
        #expect(savedSpot.id == originalSpot.id)
        #expect(savedSpot.name == "Updated Name")
        #expect(savedSpot.latitude == 40.7128)
        #expect(savedSpot.longitude == -74.0060)
        #expect(savedSpot.remoteId == "remote-456")
    }

    @Test("Save updates only mutable fields and preserves others")
    func testSaveUpdatesOnlyMutableFields() async throws {
        let originalDate = Date(timeIntervalSince1970: 1000)
        let originalSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: originalDate,
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = Spot(
            id: originalSpot.id, // Same ID to find the existing record
            mapkitId: "different-mapkit", // Different mapkitId (should be ignored/preserved)
            remoteId: "updated-remote-id",
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 2000), // Different date (should be ignored/preserved)
        )

        let savedSpot = try await repository.save(spot: updatedSpot)

        // Mutable fields should be updated
        #expect(savedSpot.name == "Updated Name")
        #expect(savedSpot.latitude == 40.7128)
        #expect(savedSpot.longitude == -74.0060)
        #expect(savedSpot.remoteId == "updated-remote-id")

        // Immutable fields should be preserved from original spot
        #expect(savedSpot.id == originalSpot.id)
        #expect(savedSpot.mapkitId == originalSpot.mapkitId)
        #expect(savedSpot.createdAt == originalDate)
    }

    @Test("Save creates new spot when no matching IDs found")
    func testSaveCreatesNewSpotWhenNoMatch() async throws {
        let existingSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Existing Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: existingSpot)

        let newSpot = Spot(
            id: UUID(), // Different ID
            mapkitId: "different-mapkit", // Different mapkitId
            remoteId: "different-remote", // Different remoteId
            name: "New Spot",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: .now,
        )

        let savedSpot = try await repository.save(spot: newSpot)

        // Should create a new spot
        #expect(savedSpot.id == newSpot.id)
        #expect(savedSpot.name == "New Spot")

        // Verify both spots exist
        let allSpots = try await repository.fetchSpots()
        #expect(allSpots.count == 2)
    }
}
