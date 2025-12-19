import EatadakiData
import EatadakiSpotsKit
import Foundation
import MapKit
import Testing

@Suite("SpotInfoSummary Tests")
struct SpotInfoSummaryTests {
    @Test("init from spot sets correct id")
    func testInitFromSpotSetsCorrectId() {
        let spotId = UUID()
        let spot = SpotRecord(
            id: spotId,
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )

        let listing = SpotInfoSummary(from: spot)

        #expect(listing.id == spotId)
    }

    @Test("init from spot sets correct name")
    func testInitFromSpotSetsCorrectName() {
        let spot = SpotRecord.peacePagoda

        let listing = SpotInfoSummary(from: spot)

        #expect(listing.name == "Peace Pagoda")
    }

    @Test("init from spot sets correct coordinates")
    func testInitFromSpotSetsCorrectCoordinates() {
        let spot = SpotRecord.peacePagoda

        let listing = SpotInfoSummary(from: spot)

        #expect(listing.coordinates.latitude == 37.7849447)
        #expect(listing.coordinates.longitude == -122.4303306)
    }

    @Test("init from spot with different coordinates")
    func testInitFromSpotWithDifferentCoordinates() {
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: .now,
        )

        let listing = SpotInfoSummary(from: spot)

        #expect(listing.coordinates.latitude == 40.7128)
        #expect(listing.coordinates.longitude == -74.0060)
    }

    @Test("SpotInfoSummary is Identifiable")
    func testSpotInfoSummaryIsIdentifiable() {
        let spot = SpotRecord.peacePagoda

        let listing = SpotInfoSummary(from: spot)

        // Verify it conforms to Identifiable by checking it has an id property
        let identifiableId: UUID = listing.id
        #expect(identifiableId == spot.id)
    }
}
