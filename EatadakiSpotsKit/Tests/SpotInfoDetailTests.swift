import EatadakiData
import EatadakiSpotsKit
import Foundation
import MapKit
import Testing

@Suite("SpotInfoDetail Tests")
struct SpotInfoDetailTests {
    @Test("init from spot sets correct id")
    func testInitFromSpotSetsCorrectId() {
        let spotId = UUID()
        let spot = Spot(
            id: spotId,
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let detail = SpotInfoDetail(from: spot)

        #expect(detail.id == spotId)
    }

    @Test("init from spot sets correct name")
    func testInitFromSpotSetsCorrectName() {
        let spot = Spot(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Peace Pagoda",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let detail = SpotInfoDetail(from: spot)

        #expect(detail.name == "Peace Pagoda")
    }

    @Test("init from spot sets correct coordinates")
    func testInitFromSpotSetsCorrectCoordinates() {
        let spot = Spot(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let detail = SpotInfoDetail(from: spot)

        #expect(detail.coordinates.latitude == 37.7849447)
        #expect(detail.coordinates.longitude == -122.4303306)
    }

    @Test("init from spot with different coordinates")
    func testInitFromSpotWithDifferentCoordinates() {
        let spot = Spot(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: .now,
        )

        let detail = SpotInfoDetail(from: spot)

        #expect(detail.coordinates.latitude == 40.7128)
        #expect(detail.coordinates.longitude == -74.0060)
    }

    @Test("SpotInfoDetail is Identifiable")
    func testSpotInfoDetailIsIdentifiable() {
        let spot = Spot(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let detail = SpotInfoDetail(from: spot)

        // Verify it conforms to Identifiable by checking it has an id property
        let identifiableId: UUID = detail.id
        #expect(identifiableId == spot.id)
    }
}

