#if DEBUG
import Foundation

public class FakeSpotsRepository: SpotsRepository {
    public init(_ configure: (FakeSpotsRepository) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsFetchSpotWithID: [UUID] = []
    public var stubFetchSpotWithID: (UUID) async throws(SpotsRepositoryError) -> Spot = { id in
        Spot(id: id, name: "Fake Spot", createdAt: .now)
    }

    public func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> Spot {
        invocationsFetchSpotWithID.append(id)
        return try await stubFetchSpotWithID(id)
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
}
#endif
