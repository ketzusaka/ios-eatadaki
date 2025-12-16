import EatadakiData
import Foundation
import Testing

@Suite("Spot Tests")
struct SpotTests {
    @Test("Update updates name")
    func testUpdateUpdatesName() {
        var spot = Spot(
            id: UUID(),
            mapkitId: "original-mapkit",
            remoteId: "original-remote",
            name: "Original Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            mapkitId: "new-mapkit",
            remoteId: "new-remote",
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 1000),
        )

        spot.update(with: updatedSpot)

        #expect(spot.name == "Updated Name")
    }

    @Test("Update updates latitude")
    func testUpdateUpdatesLatitude() {
        var spot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 40.7128,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        spot.update(with: updatedSpot)

        #expect(spot.latitude == 40.7128)
    }

    @Test("Update updates longitude")
    func testUpdateUpdatesLongitude() {
        var spot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        spot.update(with: updatedSpot)

        #expect(spot.longitude == -74.0060)
    }

    @Test("Update updates remoteId")
    func testUpdateUpdatesRemoteId() {
        var spot = Spot(
            id: UUID(),
            remoteId: "original-remote",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            remoteId: "new-remote",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        spot.update(with: updatedSpot)

        #expect(spot.remoteId == "new-remote")
    }

    @Test("Update sets remoteId to nil when updated spot has nil remoteId")
    func testUpdateSetsRemoteIdToNil() {
        var spot = Spot(
            id: UUID(),
            remoteId: "original-remote",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            remoteId: nil,
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        spot.update(with: updatedSpot)

        #expect(spot.remoteId == nil)
    }

    @Test("Update does not change id")
    func testUpdateDoesNotChangeId() {
        let originalId = UUID()
        var spot = Spot(
            id: originalId,
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        spot.update(with: updatedSpot)

        #expect(spot.id == originalId)
    }

    @Test("Update does not change mapkitId")
    func testUpdateDoesNotChangeMapkitId() {
        var spot = Spot(
            id: UUID(),
            mapkitId: "original-mapkit",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        let updatedSpot = Spot(
            id: UUID(),
            mapkitId: "new-mapkit",
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 0),
        )

        spot.update(with: updatedSpot)

        #expect(spot.mapkitId == "original-mapkit")
    }

    @Test("Update does not change createdAt")
    func testUpdateDoesNotChangeCreatedAt() {
        let originalDate = Date(timeIntervalSince1970: 0)
        var spot = Spot(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: originalDate,
        )

        let updatedSpot = Spot(
            id: UUID(),
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 1000),
        )

        spot.update(with: updatedSpot)

        #expect(spot.createdAt == originalDate)
    }

    @Test("Update updates all mutable fields at once")
    func testUpdateUpdatesAllMutableFields() {
        let originalId = UUID()
        let originalMapkitId = "original-mapkit"
        let originalDate = Date(timeIntervalSince1970: 0)

        var spot = Spot(
            id: originalId,
            mapkitId: originalMapkitId,
            remoteId: "original-remote",
            name: "Original Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: originalDate,
        )

        let updatedSpot = Spot(
            id: UUID(),
            mapkitId: "new-mapkit",
            remoteId: "new-remote",
            name: "Updated Name",
            latitude: 40.7128,
            longitude: -74.0060,
            createdAt: Date(timeIntervalSince1970: 1000),
        )

        spot.update(with: updatedSpot)

        // Mutable fields should be updated
        #expect(spot.name == "Updated Name")
        #expect(spot.latitude == 40.7128)
        #expect(spot.longitude == -74.0060)
        #expect(spot.remoteId == "new-remote")

        // Immutable fields should remain unchanged
        #expect(spot.id == originalId)
        #expect(spot.mapkitId == originalMapkitId)
        #expect(spot.createdAt == originalDate)
    }
}
