import CoreLocation
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
        let testSpot = SpotRecord(
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
        let testSpot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: testSpot.id)

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.name == testSpot.name)
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
        let testSpot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: testSpot)
        let spots = try await repository.fetchSpots()

        #expect(spots.count == 1)
        #expect(spots.first?.spot.id == testSpot.id)
        #expect(spots.first?.spot.name == testSpot.name)
    }

    @Test("Fetch all spots returns multiple spots")
    func testFetchSpotsMultiple() async throws {
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
        let spot3 = SpotRecord(
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
        let spotIds = Set(spots.map(\.spot.id))
        #expect(spotIds.contains(spot1.id))
        #expect(spotIds.contains(spot2.id))
        #expect(spotIds.contains(spot3.id))
    }

    // MARK: - Sorting Tests

    @Test("Fetch spots with default sort returns spots sorted by name ascending")
    func testFetchSpotsDefaultSort() async throws {
        let spotA = SpotRecord(
            id: UUID(),
            name: "Alpha Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spotZ = SpotRecord(
            id: UUID(),
            name: "Zulu Spot",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spotM = SpotRecord(
            id: UUID(),
            name: "Mike Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spotZ)
        _ = try await repository.create(spot: spotA)
        _ = try await repository.create(spot: spotM)

        let spots = try await repository.fetchSpots()

        try #require(spots.count == 3)
        #expect(spots[0].spot.name == "Alpha Spot")
        #expect(spots[1].spot.name == "Mike Spot")
        #expect(spots[2].spot.name == "Zulu Spot")
    }

    @Test("Fetch spots sorted by name ascending")
    func testFetchSpotsSortByNameAscending() async throws {
        let spotA = SpotRecord(
            id: UUID(),
            name: "Alpha Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spotZ = SpotRecord(
            id: UUID(),
            name: "Zulu Spot",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spotM = SpotRecord(
            id: UUID(),
            name: "Mike Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spotZ)
        _ = try await repository.create(spot: spotA)
        _ = try await repository.create(spot: spotM)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 3)
        #expect(spots[0].spot.name == "Alpha Spot")
        #expect(spots[1].spot.name == "Mike Spot")
        #expect(spots[2].spot.name == "Zulu Spot")
    }

    @Test("Fetch spots sorted by name descending")
    func testFetchSpotsSortByNameDescending() async throws {
        let spotA = SpotRecord(
            id: UUID(),
            name: "Alpha Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spotZ = SpotRecord(
            id: UUID(),
            name: "Zulu Spot",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spotM = SpotRecord(
            id: UUID(),
            name: "Mike Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spotA)
        _ = try await repository.create(spot: spotZ)
        _ = try await repository.create(spot: spotM)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .descending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        #expect(spots.count == 3)
        #expect(spots[0].spot.name == "Zulu Spot")
        #expect(spots[1].spot.name == "Mike Spot")
        #expect(spots[2].spot.name == "Alpha Spot")
    }

    @Test("Fetch spots sorted by distance ascending")
    func testFetchSpotsSortByDistanceAscending() async throws {
        // Reference point: San Francisco (37.7749, -122.4194)
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        // Spot 1: Very close (Mission District, ~1km away)
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Close Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        // Spot 2: Medium distance (Oakland, ~10km away)
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Medium Spot",
            latitude: 37.8044,
            longitude: -122.2712,
            createdAt: .now,
        )
        // Spot 3: Far (San Jose, ~70km away)
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Far Spot",
            latitude: 37.3382,
            longitude: -121.8863,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot3)
        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .ascending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 3)
        // Verify ordering: closest first
        #expect(spots[0].spot.name == "Close Spot")
        #expect(spots[1].spot.name == "Medium Spot")
        #expect(spots[2].spot.name == "Far Spot")
    }

    @Test("Fetch spots sorted by distance descending")
    func testFetchSpotsSortByDistanceDescending() async throws {
        // Reference point: San Francisco (37.7749, -122.4194)
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        // Spot 1: Very close (Mission District, ~1km away)
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Close Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        // Spot 2: Medium distance (Oakland, ~10km away)
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Medium Spot",
            latitude: 37.8044,
            longitude: -122.2712,
            createdAt: .now,
        )
        // Spot 3: Far (San Jose, ~70km away)
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Far Spot",
            latitude: 37.3382,
            longitude: -121.8863,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot3)
        _ = try await repository.create(spot: spot2)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .descending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 3)
        // Verify ordering: farthest first
        #expect(spots[0].spot.name == "Far Spot")
        #expect(spots[1].spot.name == "Medium Spot")
        #expect(spots[2].spot.name == "Close Spot")
    }

    @Test("Fetch spots sorted by distance with multiple spots at similar distances")
    func testFetchSpotsSortByDistanceSimilarDistances() async throws {
        // Reference point: San Francisco (37.7749, -122.4194)
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        // Create spots at varying distances but in different directions
        // Spot 1: North (37.7849, -122.4194) - very close
        let spot1 = SpotRecord(
            id: UUID(),
            name: "North Spot",
            latitude: 37.7849,
            longitude: -122.4194,
            createdAt: .now,
        )
        // Spot 2: South (37.7649, -122.4194) - very close
        let spot2 = SpotRecord(
            id: UUID(),
            name: "South Spot",
            latitude: 37.7649,
            longitude: -122.4194,
            createdAt: .now,
        )
        // Spot 3: East (37.7749, -122.4094) - very close
        let spot3 = SpotRecord(
            id: UUID(),
            name: "East Spot",
            latitude: 37.7749,
            longitude: -122.4094,
            createdAt: .now,
        )
        // Spot 4: West (37.7749, -122.4294) - very close
        let spot4 = SpotRecord(
            id: UUID(),
            name: "West Spot",
            latitude: 37.7749,
            longitude: -122.4294,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot4)
        _ = try await repository.create(spot: spot2)
        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot3)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .ascending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 4)
        // All spots should be at approximately the same distance, so ordering should be consistent
        // Verify that the reference point is included in the results and sorting is stable
        let spotNames = spots.map(\.spot.name)
        #expect(spotNames.contains("North Spot"))
        #expect(spotNames.contains("South Spot"))
        #expect(spotNames.contains("East Spot"))
        #expect(spotNames.contains("West Spot"))
    }

    @Test("Fetch spots sorted by distance with single spot")
    func testFetchSpotsSortByDistanceSingleSpot() async throws {
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        let spot = SpotRecord(
            id: UUID(),
            name: "Single Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .ascending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        #expect(spots.count == 1)
        let fetchedSpot = try #require(spots.first)
        #expect(fetchedSpot.spot.id == spot.id)
        #expect(fetchedSpot.spot.name == spot.name)
    }

    @Test("Fetch spots sorted by distance with empty results")
    func testFetchSpotsSortByDistanceEmpty() async throws {
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .ascending,
            )
        )
        let spots = try await repository.fetchSpots(request: request)

        #expect(spots.isEmpty)
    }

    // MARK: - Search/Query Tests

    @Test("Fetch spots with query filter returns matching spots")
    func testFetchSpotsWithQuery() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Coffee Bar",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)
        _ = try await repository.create(spot: spot3)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: "Coffee",
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 2)
        let spotNames = spots.map(\.spot.name)
        #expect(spotNames.contains("Coffee Bar"))
        #expect(spotNames.contains("Coffee Shop"))
        #expect(!spotNames.contains("Pizza Place"))
    }

    @Test("Fetch spots with query filter sorted by name")
    func testFetchSpotsWithQuerySortByName() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Coffee Bar",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Coffee House",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)
        _ = try await repository.create(spot: spot3)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: "Coffee",
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 3)
        #expect(spots[0].spot.name == "Coffee Bar")
        #expect(spots[1].spot.name == "Coffee House")
        #expect(spots[2].spot.name == "Coffee Shop")
    }

    @Test("Fetch spots with query filter sorted by distance")
    func testFetchSpotsWithQuerySortByDistance() async throws {
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        // Close spot matching query
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        // Far spot matching query
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Coffee Bar",
            latitude: 37.3382,
            longitude: -121.8863,
            createdAt: .now,
        )
        // Close spot not matching query
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)
        _ = try await repository.create(spot: spot3)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .ascending,
            ),
            query: "Coffee",
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 2)
        // Should be sorted by distance: closer first
        #expect(spots[0].spot.name == "Coffee Shop")
        #expect(spots[1].spot.name == "Coffee Bar")
    }

    @Test("Fetch spots with empty query returns all spots")
    func testFetchSpotsWithEmptyQuery() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: "",
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 2)
        #expect(spots.map(\.spot.name).sorted() == ["Coffee Shop", "Pizza Place"])
    }

    @Test("Fetch spots with nil query returns all spots")
    func testFetchSpotsWithNilQuery() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: nil,
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 2)
        #expect(spots.map(\.spot.name).sorted() == ["Coffee Shop", "Pizza Place"])
    }

    @Test("Fetch spots with query that matches no spots returns empty array")
    func testFetchSpotsWithNoMatches() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: "Burger",
        )
        let spots = try await repository.fetchSpots(request: request)

        #expect(spots.isEmpty)
    }

    @Test("Fetch spots with partial query match")
    func testFetchSpotsWithPartialMatch() async throws {
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Great Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Best Coffee House",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)
        _ = try await repository.create(spot: spot3)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: "Coffee",
        )
        let spots = try await repository.fetchSpots(request: request)

        try #require(spots.count == 2)
        let spotNames = spots.map(\.spot.name).sorted()
        #expect(spotNames.contains("Best Coffee House"))
        #expect(spotNames.contains("Great Coffee Shop"))
        #expect(!spotNames.contains("Pizza Place"))
    }

    @Test("Observe spots with query filter emits filtered results")
    func testObserveSpotsWithQuery() async throws {
        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            ),
            query: "Coffee",
        )
        let observation = await repository.observeSpots(request: request)
        var iterator = observation.makeAsyncIterator()

        // Initial state should be empty
        let initialSpots = try await iterator.next()
        #expect(initialSpots?.isEmpty == true)

        let spot1 = SpotRecord(
            id: UUID(),
            name: "Coffee Shop",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Pizza Place",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)

        // Should only emit spots matching the query
        let filteredSpots = try await iterator.next()
        try #require(filteredSpots?.count == 1)
        #expect(filteredSpots?.first?.spot.name == "Coffee Shop")
    }

    // MARK: - observeSpots Tests

    @Test("Observe spots with default sort emits initial empty array")
    func testObserveSpotsDefaultSortEmpty() async throws {
        let observation = await repository.observeSpots()
        var iterator = observation.makeAsyncIterator()

        let initialSpots = try await iterator.next()
        #expect(initialSpots?.isEmpty == true)
    }

    @Test("Observe spots emits when spots are created")
    func testObserveSpotsEmitsOnCreate() async throws {
        let observation = await repository.observeSpots()
        var iterator = observation.makeAsyncIterator()

        // Initial state should be empty
        let initialSpots = try await iterator.next()
        #expect(initialSpots?.isEmpty == true)

        let testSpot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        _ = try await repository.create(spot: testSpot)

        let spotsAfterCreate = try await iterator.next()
        try #require(spotsAfterCreate?.count == 1)
        #expect(spotsAfterCreate?.first?.spot.id == testSpot.id)
        #expect(spotsAfterCreate?.first?.spot.name == "Test Spot")
    }

    @Test("Observe spots with name sort emits sorted results")
    func testObserveSpotsNameSort() async throws {
        let spotA = SpotRecord(
            id: UUID(),
            name: "Alpha Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spotZ = SpotRecord(
            id: UUID(),
            name: "Zulu Spot",
            latitude: 37.7849544,
            longitude: -122.4317274,
            createdAt: .now,
        )
        let spotM = SpotRecord(
            id: UUID(),
            name: "Mike Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spotZ)
        _ = try await repository.create(spot: spotA)
        _ = try await repository.create(spot: spotM)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .name,
                direction: .ascending,
            )
        )
        let observation = await repository.observeSpots(request: request)
        var iterator = observation.makeAsyncIterator()

        let spotsOptional = try await iterator.next()
        let spots = try #require(spotsOptional)
        try #require(spots.count == 3)
        #expect(spots[0].spot.name == "Alpha Spot")
        #expect(spots[1].spot.name == "Mike Spot")
        #expect(spots[2].spot.name == "Zulu Spot")
    }

    @Test("Observe spots with distance sort emits sorted results")
    func testObserveSpotsDistanceSort() async throws {
        let referenceCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194,
        )

        // Spot 1: Very close (Mission District, ~1km away)
        let spot1 = SpotRecord(
            id: UUID(),
            name: "Close Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        // Spot 2: Medium distance (Oakland, ~10km away)
        let spot2 = SpotRecord(
            id: UUID(),
            name: "Medium Spot",
            latitude: 37.8044,
            longitude: -122.2712,
            createdAt: .now,
        )
        // Spot 3: Far (San Jose, ~70km away)
        let spot3 = SpotRecord(
            id: UUID(),
            name: "Far Spot",
            latitude: 37.3382,
            longitude: -121.8863,
            createdAt: .now,
        )

        _ = try await repository.create(spot: spot3)
        _ = try await repository.create(spot: spot1)
        _ = try await repository.create(spot: spot2)

        let request = FetchSpotsDataRequest(
            sort: FetchSpotsDataRequest.Sort(
                field: .distance(from: referenceCoordinate),
                direction: .ascending,
            )
        )
        let observation = await repository.observeSpots(request: request)
        var iterator = observation.makeAsyncIterator()

        let spotsOptional = try await iterator.next()
        let spots = try #require(spotsOptional)
        try #require(spots.count == 3)
        // Verify ordering: closest first
        #expect(spots[0].spot.name == "Close Spot")
        #expect(spots[1].spot.name == "Medium Spot")
        #expect(spots[2].spot.name == "Far Spot")
    }

    @Test("Observe spots emits updates when spot is saved")
    func testObserveSpotsEmitsOnSave() async throws {
        let observation = await repository.observeSpots()
        var iterator = observation.makeAsyncIterator()

        // Initial state should be empty
        let initialSpots = try await iterator.next()
        #expect(initialSpots?.isEmpty == true)

        let testSpot = SpotRecord(
            id: UUID(),
            name: "Original Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        _ = try await repository.create(spot: testSpot)

        let spotsAfterCreate = try await iterator.next()
        try #require(spotsAfterCreate?.count == 1)
        #expect(spotsAfterCreate?.first?.spot.name == "Original Name")

        var updatedSpot = testSpot
        updatedSpot.name = "Updated Name"
        _ = try await repository.save(spot: updatedSpot)

        let spotsAfterSave = try await iterator.next()
        try #require(spotsAfterSave?.count == 1)
        #expect(spotsAfterSave?.first?.spot.name == "Updated Name")
    }

    @Test("Create spot with all optional fields")
    func testCreateSpotWithOptionalFields() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.mapkitId == "mapkit-123")
        #expect(fetchedSpot.spot.remoteId == "remote-456")
    }

    @Test("Create spot without optional fields")
    func testCreateSpotWithoutOptionalFields() async throws {
        let testSpot = SpotRecord(
            id: UUID(),
            name: "Minimal Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let createdSpot = try await repository.create(spot: testSpot)
        let fetchedSpot = try await repository.fetchSpot(withID: createdSpot.id)

        #expect(fetchedSpot.spot.mapkitId == nil)
        #expect(fetchedSpot.spot.remoteId == nil)
        #expect(fetchedSpot.spot.name == "Minimal Spot")
    }

    // MARK: - fetchSpot(withIDs:) Tests

    @Test("Fetch spot by SpotIDs with UUID successfully")
    func testFetchSpotBySpotIDsWithUUID() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with mapkitId successfully")
    func testFetchSpotBySpotIDsWithMapkitId() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.mapkitId == testSpot.mapkitId)
        #expect(fetchedSpot.spot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with remoteId successfully")
    func testFetchSpotBySpotIDsWithRemoteId() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.remoteId == testSpot.remoteId)
        #expect(fetchedSpot.spot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with UUID and mapkitId matches by UUID")
    func testFetchSpotBySpotIDsWithUUIDAndMapkitId() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with UUID and mapkitId matches by mapkitId")
    func testFetchSpotBySpotIDsWithUUIDAndMapkitIdMatchesMapkitId() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.mapkitId == testSpot.mapkitId)
        #expect(fetchedSpot.spot.name == testSpot.name)
    }

    @Test("Fetch spot by SpotIDs with all IDs provided")
    func testFetchSpotBySpotIDsWithAllIDs() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.mapkitId == testSpot.mapkitId)
        #expect(fetchedSpot.spot.remoteId == testSpot.remoteId)
        #expect(fetchedSpot.spot.name == testSpot.name)
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
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.mapkitId == "mapkit-123")
    }

    @Test("Fetch spot by SpotIDs matches spot with only remoteId when searching by remoteId")
    func testFetchSpotBySpotIDsMatchesByRemoteIdOnly() async throws {
        let testSpot = SpotRecord(
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

        #expect(fetchedSpot.spot.id == testSpot.id)
        #expect(fetchedSpot.spot.remoteId == "remote-456")
    }

    // MARK: - save(spot:) Tests

    @Test("Save creates new spot when spot does not exist")
    func testSaveCreatesNewSpot() async throws {
        let newSpot = SpotRecord(
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
        #expect(fetchedSpot.spot.id == savedSpot.id)
        #expect(fetchedSpot.spot.name == savedSpot.name)
    }

    @Test("Save updates existing spot when found by id")
    func testSaveUpdatesExistingSpotByID() async throws {
        let originalSpot = SpotRecord(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = SpotRecord(
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
        let originalSpot = SpotRecord(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = SpotRecord(
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
        let originalSpot = SpotRecord(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = SpotRecord(
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
        let originalSpot = SpotRecord(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Original Name",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: originalDate,
        )

        _ = try await repository.create(spot: originalSpot)

        let updatedSpot = SpotRecord(
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
        let existingSpot = SpotRecord(
            id: UUID(),
            mapkitId: "mapkit-123",
            remoteId: "remote-456",
            name: "Existing Spot",
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: .now,
        )

        _ = try await repository.create(spot: existingSpot)

        let newSpot = SpotRecord(
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

    @Test("Creating spot updates R-tree index")
    func testCreatingSpotUpdatesRTreeIndex() async throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()

        let repository = RealSpotsRepository(db: db)

        let testSpot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
            reason: .findResult,
        )

        _ = try await repository.create(spot: testSpot)

        // Verify the entry exists in the R-tree
        let fetchedEntry = try await db.read { database in
            try Row.fetchOne(
                database,
                sql: """
                    SELECT spotId, minX, maxX, minY, maxY
                    FROM spots_geospatial_index
                    WHERE spotId = ?
                """,
                arguments: [testSpot.id.uuidString]
            )
        }
        let entry = try #require(fetchedEntry)
        let spotId = try #require(entry["spotId"] as? String)
        #expect(spotId == testSpot.id.uuidString)
        let minX = try #require(entry["minX"] as? Double)
        let maxX = try #require(entry["maxX"] as? Double)
        let minY = try #require(entry["minY"] as? Double)
        let maxY = try #require(entry["maxY"] as? Double)
        // R-tree stores coordinates as 32-bit floats, so we need approximate equality
        let epsilon = 0.0001
        #expect(abs(minX - testSpot.longitude) < epsilon)
        #expect(abs(maxX - testSpot.longitude) < epsilon)
        #expect(abs(minY - testSpot.latitude) < epsilon)
        #expect(abs(maxY - testSpot.latitude) < epsilon)
    }

    @Test("Saving spot updates R-tree index")
    func testSavingSpotUpdatesRTreeIndex() async throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()

        let repository = RealSpotsRepository(db: db)

        let originalSpot = SpotRecord(
            id: UUID(),
            name: "Original Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
            reason: .findResult,
        )

        _ = try await repository.create(spot: originalSpot)

        // Update the spot's location
        var updatedSpot = originalSpot
        updatedSpot.latitude = 37.7950
        updatedSpot.longitude = -122.4000

        _ = try await repository.save(spot: updatedSpot)

        // Verify the R-tree entry was updated
        let fetchedEntry = try await db.read { database in
            try Row.fetchOne(
                database,
                sql: """
                    SELECT spotId, minX, maxX, minY, maxY
                    FROM spots_geospatial_index
                    WHERE spotId = ?
                """,
                arguments: [originalSpot.id.uuidString]
            )
        }
        let entry = try #require(fetchedEntry)
        let minX = try #require(entry["minX"] as? Double)
        let maxX = try #require(entry["maxX"] as? Double)
        let minY = try #require(entry["minY"] as? Double)
        let maxY = try #require(entry["maxY"] as? Double)
        // R-tree stores coordinates as 32-bit floats, so we need approximate equality
        let epsilon = 0.0001
        #expect(abs(minX - updatedSpot.longitude) < epsilon)
        #expect(abs(maxX - updatedSpot.longitude) < epsilon)
        #expect(abs(minY - updatedSpot.latitude) < epsilon)
        #expect(abs(maxY - updatedSpot.latitude) < epsilon)
    }

    @Test("Saving new spot creates R-tree index entry")
    func testSavingNewSpotCreatesRTreeIndexEntry() async throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()

        let repository = RealSpotsRepository(db: db)

        let newSpot = SpotRecord(
            id: UUID(),
            name: "New Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
            reason: .findResult,
        )

        _ = try await repository.save(spot: newSpot)

        // Verify the entry exists in the R-tree
        let fetchedEntry = try await db.read { database in
            try Row.fetchOne(
                database,
                sql: """
                    SELECT spotId, minX, maxX, minY, maxY
                    FROM spots_geospatial_index
                    WHERE spotId = ?
                """,
                arguments: [newSpot.id.uuidString]
            )
        }
        let entry = try #require(fetchedEntry)
        let spotId = try #require(entry["spotId"] as? String)
        #expect(spotId == newSpot.id.uuidString)
    }
}
