import CoreLocation
import EatadakiData
import EatadakiExperiencesKit
import Foundation
import Testing

@Suite("RealSpotSearcher Tests")
struct RealSpotSearcherTests {
    @Test("findAndCacheSpots calls provider and saves all spots to repository")
    func testFindAndCacheSpotsSavesAllSpots() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let foundSpot1 = FoundSpot(
            id: UUID(),
            remoteId: nil,
            mapkitId: "mapkit-id-1",
            name: "Test Restaurant 1",
            latitude: 37.7850,
            longitude: -122.4294,
        )
        let foundSpot2 = FoundSpot(
            id: UUID(),
            remoteId: nil,
            mapkitId: "mapkit-id-2",
            name: "Test Restaurant 2",
            latitude: 37.7860,
            longitude: -122.4304,
        )

        fakeProvider.stubFindSpots = { _ in
            FindSpotsResponse(spots: [foundSpot1, foundSpot2])
        }

        try await searcher.findAndCacheSpots(request: testRequest)

        #expect(fakeProvider.invocationsFindSpots.count == 1)
        #expect(fakeProvider.invocationsFindSpots.first?.query == "restaurant")
        #expect(fakeRepository.invocationsSave.count == 2)

        let savedSpots = fakeRepository.invocationsSave
        #expect(savedSpots[0].name == "Test Restaurant 1")
        #expect(savedSpots[0].mapkitId == "mapkit-id-1")
        #expect(savedSpots[0].latitude == 37.7850)
        #expect(savedSpots[0].longitude == -122.4294)
        #expect(savedSpots[1].name == "Test Restaurant 2")
        #expect(savedSpots[1].mapkitId == "mapkit-id-2")
        #expect(savedSpots[1].latitude == 37.7860)
        #expect(savedSpots[1].longitude == -122.4304)
    }

    @Test("findAndCacheSpots handles empty results")
    func testFindAndCacheSpotsHandlesEmptyResults() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
        )

        fakeProvider.stubFindSpots = { _ in
            FindSpotsResponse(spots: [])
        }

        try await searcher.findAndCacheSpots(request: testRequest)

        #expect(fakeProvider.invocationsFindSpots.count == 1)
        #expect(fakeRepository.invocationsSave.isEmpty)
    }

    @Test("findAndCacheSpots converts FoundSpot to Spot correctly")
    func testFindAndCacheSpotsConvertsFoundSpotToSpot() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "cafe",
        )

        let foundSpotId = UUID()
        let foundSpot = FoundSpot(
            id: foundSpotId,
            remoteId: "remote-id-123",
            mapkitId: "mapkit-id-456",
            name: "Test Cafe",
            latitude: 40.7128,
            longitude: -74.0060,
        )

        fakeProvider.stubFindSpots = { (_) async throws(SpotsSearcherError) -> FindSpotsResponse in
            FindSpotsResponse(spots: [foundSpot])
        }

        try await searcher.findAndCacheSpots(request: testRequest)

        #expect(fakeRepository.invocationsSave.count == 1)
        let savedSpot = fakeRepository.invocationsSave.first
        try #require(savedSpot != nil)
        #expect(savedSpot?.id == foundSpotId)
        #expect(savedSpot?.remoteId == "remote-id-123")
        #expect(savedSpot?.mapkitId == "mapkit-id-456")
        #expect(savedSpot?.name == "Test Cafe")
        #expect(savedSpot?.latitude == 40.7128)
        #expect(savedSpot?.longitude == -74.0060)
    }

    @Test("findAndCacheSpots throws providerError when provider fails")
    func testFindAndCacheSpotsThrowsProviderError() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        fakeProvider.stubFindSpots = { (_) async throws(SpotsSearcherError) -> FindSpotsResponse in
            throw SpotsSearcherError.providerError("Provider failed")
        }

        await #expect(throws: SpotsSearcherError.providerError("Provider failed")) {
            try await searcher.findAndCacheSpots(request: testRequest)
        }

        #expect(fakeProvider.invocationsFindSpots.count == 1)
        #expect(fakeRepository.invocationsSave.isEmpty)
    }

    @Test("findAndCacheSpots throws failedToSaveSpot when repository save fails")
    func testFindAndCacheSpotsThrowsFailedToSaveSpot() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let foundSpot = FoundSpot(
            id: UUID(),
            remoteId: nil,
            mapkitId: "mapkit-id-1",
            name: "Test Restaurant",
            latitude: 37.7850,
            longitude: -122.4294,
        )

        fakeProvider.stubFindSpots = { _ in
            FindSpotsResponse(spots: [foundSpot])
        }

        let repositoryError = SpotsRepositoryError.databaseError("Database save failed")
        fakeRepository.stubSave = { (_) async throws(SpotsRepositoryError) -> SpotRecord in
            throw repositoryError
        }

        await #expect(throws: SpotsSearcherError.failedToSaveSpot(repositoryError)) {
            try await searcher.findAndCacheSpots(request: testRequest)
        }

        #expect(fakeProvider.invocationsFindSpots.count == 1)
        #expect(fakeRepository.invocationsSave.count == 1)
    }

    @Test("findAndCacheSpots stops saving on first repository error")
    func testFindAndCacheSpotsStopsOnFirstError() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let foundSpot1 = FoundSpot(
            id: UUID(),
            remoteId: nil,
            mapkitId: "mapkit-id-1",
            name: "Test Restaurant 1",
            latitude: 37.7850,
            longitude: -122.4294,
        )
        let foundSpot2 = FoundSpot(
            id: UUID(),
            remoteId: nil,
            mapkitId: "mapkit-id-2",
            name: "Test Restaurant 2",
            latitude: 37.7860,
            longitude: -122.4304,
        )

        fakeProvider.stubFindSpots = { _ in
            FindSpotsResponse(spots: [foundSpot1, foundSpot2])
        }

        var saveCallCount = 0
        let repositoryError = SpotsRepositoryError.databaseError("Database save failed")
        fakeRepository.stubSave = { (_) async throws(SpotsRepositoryError) -> SpotRecord in
            saveCallCount += 1
            if saveCallCount == 1 {
                throw repositoryError
            }
            return SpotRecord(
                id: UUID(),
                name: "Should not reach here",
                latitude: 0,
                longitude: 0,
                createdAt: .now
            )
        }

        await #expect(throws: SpotsSearcherError.failedToSaveSpot(repositoryError)) {
            try await searcher.findAndCacheSpots(request: testRequest)
        }

        #expect(fakeRepository.invocationsSave.count == 1)
        #expect(saveCallCount == 1)
    }

    @Test("findAndCacheSpots passes request correctly to provider")
    func testFindAndCacheSpotsPassesRequestCorrectly() async throws {
        let fakeRepository = FakeSpotsRepository()
        let fakeProvider = FakeSpotsProvider()
        let searcher = RealSpotSearcher(
            spotsRepository: fakeRepository,
            spotsProvider: fakeProvider,
        )

        let testLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let testRequest = FindSpotsRequest(
            location: testLocation,
            query: "pizza",
        )

        fakeProvider.stubFindSpots = { _ in
            FindSpotsResponse(spots: [])
        }

        try await searcher.findAndCacheSpots(request: testRequest)

        #expect(fakeProvider.invocationsFindSpots.count == 1)
        let passedRequest = try #require(fakeProvider.invocationsFindSpots.first)
        #expect(passedRequest.location?.coordinate.latitude == testLocation.coordinate.latitude)
        #expect(passedRequest.location?.coordinate.longitude == testLocation.coordinate.longitude)
        #expect(passedRequest.query == "pizza")
    }
}
