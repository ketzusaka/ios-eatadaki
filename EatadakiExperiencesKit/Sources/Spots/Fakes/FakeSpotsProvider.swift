#if DEBUG
import Foundation

public class FakeSpotsProvider: SpotsProvider {
    public init() {}

    public private(set) var invocationsFindSpots: [FindSpotsRequest] = []
    public var stubFindSpots: (FindSpotsRequest) async throws(SpotsSearcherError) -> FindSpotsResponse = { _ in
        FindSpotsResponse()
    }

    public func findSpots(request: FindSpotsRequest) async throws(SpotsSearcherError) -> FindSpotsResponse {
        invocationsFindSpots.append(request)
        return try await stubFindSpots(request)
    }
}
#endif
