#if DEBUG
import Foundation

public class FakeSpotsRepository: SpotsRepository {
    public init(_ configure: (FakeSpotsRepository) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsFetchSpotWithID: [UUID] = []
    public var stubFetchSpotWithID: (UUID) async throws(SpotsRepositoryError) -> Spot = { id in
        Spot(
            id: id,
            name: "Fake Spot",
            latitude: 37.7850,
            longitude: -122.4294,
            createdAt: .now,
        )
    }

    public func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> Spot {
        invocationsFetchSpotWithID.append(id)
        return try await stubFetchSpotWithID(id)
    }

    public private(set) var invocationsFetchSpotWithIDs: [SpotIDs] = []
    public var stubFetchSpotWithIDs: (SpotIDs) async throws(SpotsRepositoryError) -> Spot = { ids in
        Spot(
            id: ids.id ?? UUID(),
            mapkitId: ids.mapkitId,
            remoteId: ids.remoteId,
            name: "Fake Spot",
            latitude: 37.7850,
            longitude: -122.4294,
            createdAt: .now,
        )
    }

    public func fetchSpot(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> Spot {
        invocationsFetchSpotWithIDs.append(ids)
        return try await stubFetchSpotWithIDs(ids)
    }

    public private(set) var invokedCountFetchSpots: Int = 0
    public var stubFetchSpots: () async throws(SpotsRepositoryError) -> [Spot] = {
        []
    }

    public func fetchSpots() async throws(SpotsRepositoryError) -> [Spot] {
        invokedCountFetchSpots += 1
        return try await stubFetchSpots()
    }

    public private(set) var invocationsCreate: [Spot] = []
    public var stubCreate: (Spot) async throws(SpotsRepositoryError) -> Spot = { spot in
        spot
    }

    public func create(spot: Spot) async throws(SpotsRepositoryError) -> Spot {
        invocationsCreate.append(spot)
        return try await stubCreate(spot)
    }

    public private(set) var invocationsSave: [Spot] = []
    public var stubSave: (Spot) async throws(SpotsRepositoryError) -> Spot = { spot in
        spot
    }

    public func save(spot: Spot) async throws(SpotsRepositoryError) -> Spot {
        invocationsSave.append(spot)
        return try await stubSave(spot)
    }
}
#endif
