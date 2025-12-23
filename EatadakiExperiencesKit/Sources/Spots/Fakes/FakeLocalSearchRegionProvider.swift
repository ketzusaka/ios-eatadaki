#if DEBUG
import MapKit

public class FakeLocalSearchRegionProvider: LocalSearchRegionProvider {
    public init(_ configure: (FakeLocalSearchRegionProvider) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsCreateSearch: [MKLocalPointsOfInterestRequest] = []
    public var stubCreateSearch: (MKLocalPointsOfInterestRequest) -> any LocalSearch = { _ in
        FakeLocalSearch()
    }

    public func createSearch(request: MKLocalPointsOfInterestRequest) -> any LocalSearch {
        invocationsCreateSearch.append(request)
        return stubCreateSearch(request)
    }
}
#endif
