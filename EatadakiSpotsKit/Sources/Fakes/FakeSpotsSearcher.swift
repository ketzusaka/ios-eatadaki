public class FakeSpotsSearcher: SpotsSearcher {
    public init() {}

    public private(set) var invocationsFindAndCacheSpots = [FindSpotsRequest]()
    public var stubFindAndCacheSpots: (FindSpotsRequest) async throws(SpotsSearcherError) -> Void = { _ in }
    public func findAndCacheSpots(request: FindSpotsRequest) async throws(SpotsSearcherError) {
        invocationsFindAndCacheSpots.append(request)
        try await stubFindAndCacheSpots(request)
    }
}
