import CoreLocation
import EatadakiData
import EatadakiSpotsKit
import Foundation
import MapKit
import Testing

@Suite("MapKitSpotsProvider Tests")
struct MapKitSpotsProviderTests {
    @Test("findSpots uses request provider when query is provided")
    func testFindSpotsUsesRequestProvider() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let fakeSearch = FakeLocalSearch()
        let mockResponse = createMockResponse()
        fakeSearch.stubSearch = { mockResponse }
        fakeRequestProvider.stubCreateSearch = { _ in fakeSearch }

        let result = try await provider.findSpots(request: testRequest)

        #expect(fakeRequestProvider.invocationsCreateSearch.count == 1)
        #expect(fakeRequestProvider.invocationsCreateSearch.first?.naturalLanguageQuery == "restaurant")
        #expect(fakeRegionProvider.invocationsCreateSearch.isEmpty)

        #expect(result.spots.count == 2)
    }

    @Test("findSpots uses region provider when only location is provided")
    func testFindSpotsUsesRegionProvider() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testLocation = CLLocation(latitude: 37.7850, longitude: -122.4294)
        let testRequest = FindSpotsRequest(
            location: testLocation,
            query: nil,
        )

        let fakeSearch = FakeLocalSearch()
        let mockResponse = createMockResponse()
        fakeSearch.stubSearch = { mockResponse }
        fakeRegionProvider.stubCreateSearch = { _ in fakeSearch }

        let result = try await provider.findSpots(request: testRequest)

        #expect(fakeRegionProvider.invocationsCreateSearch.count == 1)
        // Note: MKLocalPointsOfInterestRequest doesn't expose center as a readable property
        // We verify it was called with the correct request type
        #expect(fakeRequestProvider.invocationsCreateSearch.isEmpty)
        #expect(result.spots.count == 2)
    }

    @Test("findSpots throws invalidRequest when neither query nor location provided")
    func testFindSpotsThrowsInvalidRequest() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testRequest = FindSpotsRequest(location: nil, query: nil)

        await #expect(throws: SpotsSearcherError.invalidRequest("A query or location is required.")) {
            try await provider.findSpots(request: testRequest)
        }

        #expect(fakeRequestProvider.invocationsCreateSearch.isEmpty)
        #expect(fakeRegionProvider.invocationsCreateSearch.isEmpty)
    }

    @Test("findSpots converts mapItems to FoundSpots correctly")
    func testFindSpotsConvertsMapItems() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let fakeSearch = FakeLocalSearch()
        let peacePlaza = makeMockPeacePadoga()
        let kinokuniya = makeMockKinokuniya()
        let mockResponse = createMockResponse(mapItems: [peacePlaza, kinokuniya])
        fakeSearch.stubSearch = { mockResponse }
        fakeRequestProvider.stubCreateSearch = { _ in fakeSearch }

        let result = try await provider.findSpots(request: testRequest)

        try #require(result.spots.count == 2)
        #expect(result.spots[0].name == Spot.peacePagoda.name)
        #expect(result.spots[0].mapkitId == Spot.peacePagoda.mapkitId)
        #expect(result.spots[0].latitude == Spot.peacePagoda.latitude)
        #expect(result.spots[0].longitude == Spot.peacePagoda.longitude)
        #expect(result.spots[1].name == Spot.kinokuniya.name)
        #expect(result.spots[1].mapkitId == Spot.kinokuniya.mapkitId)
        #expect(result.spots[1].latitude == Spot.kinokuniya.latitude)
        #expect(result.spots[1].longitude == Spot.kinokuniya.longitude)
    }

    @Test("findSpots filters out mapItems without identifier")
    func testFindSpotsFiltersMissingIdentifier() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let fakeSearch = FakeLocalSearch()
        let mockResponse = createMockResponseWithMissingIdentifier()
        fakeSearch.stubSearch = { mockResponse }
        fakeRequestProvider.stubCreateSearch = { _ in fakeSearch }

        let result = try await provider.findSpots(request: testRequest)

        #expect(result.spots.count == 1)
        let spot = try #require(result.spots.first)
        #expect(spot.name == Spot.peacePagoda.name)
    }

    @Test("findSpots filters out mapItems without name")
    func testFindSpotsFiltersMissingName() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let fakeSearch = FakeLocalSearch()
        let mockResponse = createMockResponseWithMissingName()
        fakeSearch.stubSearch = { mockResponse }
        fakeRequestProvider.stubCreateSearch = { _ in fakeSearch }

        let result = try await provider.findSpots(request: testRequest)

        try #require(result.spots.count == 2)
        #expect(result.spots[0].name == Spot.peacePagoda.name)
        #expect(result.spots[0].mapkitId == Spot.peacePagoda.mapkitId)
        #expect(result.spots[0].latitude == Spot.peacePagoda.latitude)
        #expect(result.spots[0].longitude == Spot.peacePagoda.longitude)
        #expect(result.spots[1].name == "Unknown Location")
        #expect(result.spots[1].mapkitId == Spot.kinokuniya.mapkitId)
    }

    @Test("findSpots wraps search errors in providerError")
    func testFindSpotsWrapsSearchErrors() async throws {
        let fakeRequestProvider = FakeLocalSearchRequestProvider()
        let fakeRegionProvider = FakeLocalSearchRegionProvider()
        let provider = MapKitSpotsProvider(
            requestProvider: fakeRequestProvider,
            regionProvider: fakeRegionProvider,
        )

        let testRequest = FindSpotsRequest(
            location: CLLocation(latitude: 37.7850, longitude: -122.4294),
            query: "restaurant",
        )

        let fakeSearch = FakeLocalSearch()
        fakeSearch.stubSearch = { () async throws(LocalSearchError) -> MKLocalSearch.Response in
            throw LocalSearchError.providerError("Test error")
        }
        fakeRequestProvider.stubCreateSearch = { _ in fakeSearch }

        await #expect(throws: SpotsSearcherError.providerError("Test error")) {
            try await provider.findSpots(request: testRequest)
        }
    }

    // MARK: - Helpers

    private func createMockResponse(mapItems: [TestableMapItem]? = nil) -> MKLocalSearch.Response {
        MKLocalSearch.TestableResponse {
            $0.stubMapItems = mapItems == nil ? [makeMockPeacePadoga(), makeMockKinokuniya()] : mapItems!
        }
    }

    private func createMockResponseWithMissingIdentifier() -> MKLocalSearch.Response {
        MKLocalSearch.TestableResponse {
            $0.stubMapItems = [
                makeMockPeacePadoga(),
                makeMockKinokuniya(includeIdentifier: false),
            ]
        }
    }

    private func createMockResponseWithMissingName() -> MKLocalSearch.Response {
        MKLocalSearch.TestableResponse {
            $0.stubMapItems = [
                makeMockPeacePadoga(),
                makeMockKinokuniya(includeName: false),
            ]
        }
    }

    private func makeMockPeacePadoga(
        includeIdentifier: Bool = true,
        includeName: Bool = true,
    ) -> TestableMapItem {
        createMockMapItem(
            identifier: includeIdentifier ? Spot.peacePagoda.mapkitId : nil,
            name: includeName ? Spot.peacePagoda.name : nil,
            latitude: Spot.peacePagoda.latitude,
            longitude: Spot.peacePagoda.longitude,
        )
    }

    private func makeMockKinokuniya(
        includeIdentifier: Bool = true,
        includeName: Bool = true,
    ) -> TestableMapItem {
        createMockMapItem(
            identifier: includeIdentifier ? Spot.kinokuniya.mapkitId : nil,
            name: includeName ? Spot.kinokuniya.name : nil,
            latitude: Spot.kinokuniya.latitude,
            longitude: Spot.kinokuniya.longitude,
        )
    }

    private func createMockMapItem(
        identifier: String?,
        name: String?,
        latitude: Double,
        longitude: Double,
    ) -> TestableMapItem {
        TestableMapItem {
            if let identifier {
                $0.stubIdentifier = MKMapItem.Identifier(rawValue: identifier)
            }
            $0.stubLocation = CLLocation(latitude: latitude, longitude: longitude)
            $0.name = name
        }
    }
}
