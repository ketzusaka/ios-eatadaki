import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("RealSpotsRepository Tests")
struct SpotsRepositoryTests {
    
    @Test("Create spot successfully")
    func testCreateSpot() async throws {
        let repository = try setupRepository()
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "test-mapkit-id",
            remoteId: "test-remote-id",
            name: "Test Spot",
            createdAt: .now
        )
        
        let createdSpot = try await repository.create(spot: testSpot)
        
        #expect(createdSpot.id == testSpot.id)
        #expect(createdSpot.name == testSpot.name)
        #expect(createdSpot.mapkitId == testSpot.mapkitId)
        #expect(createdSpot.remoteId == testSpot.remoteId)
    }
    
    @Test("Fetch spot by ID successfully")
    func testFetchSpotByID() async throws {
        let repository = try setupRepository()
        let testSpot = Spot(
            id: UUID(),
            name: "Test Spot",
            createdAt: .now
        )
        
        _ = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: testSpot.id)
        
        #expect(fetchedSpot.id == testSpot.id)
        #expect(fetchedSpot.name == testSpot.name)
    }
    
    @Test("Fetch spot by ID throws notFound when spot does not exist")
    func testFetchSpotByIDNotFound() async throws {
        let repository = try setupRepository()
        let nonExistentID = UUID()
        
        await #expect(throws: RepositoryError.notFound) {
            try await repository.fetchSpot(withID: nonExistentID)
        }
    }
    
    @Test("Fetch all spots returns empty array when no spots exist")
    func testFetchSpotsEmpty() async throws {
        let repository = try setupRepository()
        
        let spots = try await repository.fetchSpots()
        
        #expect(spots.isEmpty == true)
    }
    
    @Test("Fetch all spots returns single spot")
    func testFetchSpotsSingle() async throws {
        let repository = try setupRepository()
        let testSpot = Spot(
            id: UUID(),
            name: "Test Spot",
            createdAt: .now
        )
        
        _ = try await repository.create(spot: testSpot)
        let spots = try await repository.fetchSpots()
        
        #expect(spots.count == 1)
        #expect(spots.first?.id == testSpot.id)
        #expect(spots.first?.name == testSpot.name)
    }
    
    @Test("Fetch all spots returns multiple spots in correct order")
    func testFetchSpotsMultiple() async throws {
        let repository = try setupRepository()
        let spot1 = Spot(
            id: UUID(),
            name: "Spot 1",
            createdAt: .now
        )
        let spot2 = Spot(
            id: UUID(),
            name: "Spot 2",
            createdAt: .now
        )
        let spot3 = Spot(
            id: UUID(),
            name: "Spot 3",
            createdAt: .now
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
        let repository = try setupRepository()
        let testSpot = Spot(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Full Spot",
            createdAt: .now
        )
        
        let createdSpot = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: createdSpot.id)
        
        #expect(fetchedSpot.mapkitId == "mapkit-123")
        #expect(fetchedSpot.remoteId == "remote-456")
    }
    
    @Test("Create spot without optional fields")
    func testCreateSpotWithoutOptionalFields() async throws {
        let repository = try setupRepository()
        let testSpot = Spot(
            id: UUID(),
            name: "Minimal Spot",
            createdAt: .now
        )
        
        let createdSpot = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: createdSpot.id)
        
        #expect(fetchedSpot.mapkitId == nil)
        #expect(fetchedSpot.remoteId == nil)
        #expect(fetchedSpot.name == "Minimal Spot")
    }
    
    // MARK: - Helpers
    
    private func createInMemoryDatabase() throws -> DatabaseQueue {
        try DatabaseQueue()
    }
    
    private func setupRepository() throws -> RealSpotsRepository {
        let db = try createInMemoryDatabase()
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()
        return RealSpotsRepository(db: db)
    }
}
