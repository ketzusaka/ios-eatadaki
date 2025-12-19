#if DEBUG
import Foundation

public class FakeSpotsRepository: SpotsRepository {
    public init(_ configure: (FakeSpotsRepository) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsFetchSpotWithID: [UUID] = []
    public var stubFetchSpotWithID: (UUID) async throws(SpotsRepositoryError) -> SpotRecord = { id in
        SpotRecord(
            id: id,
            name: "Fake Spot",
            latitude: 37.7850,
            longitude: -122.4294,
            createdAt: .now,
        )
    }

    public func fetchSpot(withID id: UUID) async throws(SpotsRepositoryError) -> SpotRecord {
        invocationsFetchSpotWithID.append(id)
        return try await stubFetchSpotWithID(id)
    }

    public private(set) var invocationsFetchSpotWithIDs: [SpotIDs] = []
    public var stubFetchSpotWithIDs: (SpotIDs) async throws(SpotsRepositoryError) -> SpotRecord = { ids in
        SpotRecord(
            id: ids.id ?? UUID(),
            mapkitId: ids.mapkitId,
            remoteId: ids.remoteId,
            name: "Fake Spot",
            latitude: 37.7850,
            longitude: -122.4294,
            createdAt: .now,
        )
    }

    public func fetchSpot(withIDs ids: SpotIDs) async throws(SpotsRepositoryError) -> SpotRecord {
        invocationsFetchSpotWithIDs.append(ids)
        return try await stubFetchSpotWithIDs(ids)
    }

    public private(set) var invocationsFetchSpots: [FetchSpotsDataRequest] = []
    public var stubFetchSpots: (FetchSpotsDataRequest) async throws(SpotsRepositoryError) -> [SpotRecord] = { _ in
        []
    }

    public func fetchSpots(request: FetchSpotsDataRequest = .default) async throws(SpotsRepositoryError) -> [SpotRecord] {
        invocationsFetchSpots.append(request)
        return try await stubFetchSpots(request)
    }

    public private(set) var invocationsObserveSpots: [FetchSpotsDataRequest] = []
    public var stubObserveSpots: (FetchSpotsDataRequest) -> any AsyncSequence<[SpotInfoSummary], SpotsRepositoryError> = { _ in
        struct EmptySpotsSequence: AsyncSequence {
            typealias Element = [SpotInfoSummary]
            typealias Failure = SpotsRepositoryError
            typealias AsyncIterator = Iterator

            struct Iterator: AsyncIteratorProtocol {
                mutating func next() async throws(SpotsRepositoryError) -> [SpotInfoSummary]? {
                    nil
                }
            }

            func makeAsyncIterator() -> Iterator {
                Iterator()
            }
        }
        return EmptySpotsSequence()
    }

    public func observeSpots(request: FetchSpotsDataRequest = .default) async -> any AsyncSequence<[SpotInfoSummary], SpotsRepositoryError> {
        invocationsObserveSpots.append(request)
        return stubObserveSpots(request)
    }

    public private(set) var invocationsCreate: [SpotRecord] = []
    public var stubCreate: (SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord = { spot in
        spot
    }

    public func create(spot: SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord {
        invocationsCreate.append(spot)
        return try await stubCreate(spot)
    }

    public private(set) var invocationsSave: [SpotRecord] = []
    public var stubSave: (SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord = { spot in
        spot
    }

    public func save(spot: SpotRecord) async throws(SpotsRepositoryError) -> SpotRecord {
        invocationsSave.append(spot)
        return try await stubSave(spot)
    }
}
#endif
