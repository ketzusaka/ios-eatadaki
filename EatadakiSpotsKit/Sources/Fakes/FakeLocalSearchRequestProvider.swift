#if DEBUG
import MapKit

public class FakeLocalSearchRequestProvider: LocalSearchRequestProvider {
    public init(_ configure: (FakeLocalSearchRequestProvider) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsCreateSearch: [MKLocalSearch.Request] = []
    public var stubCreateSearch: (MKLocalSearch.Request) -> any LocalSearch = { _ in
        FakeLocalSearch()
    }

    public func createSearch(request: MKLocalSearch.Request) -> any LocalSearch {
        invocationsCreateSearch.append(request)
        return stubCreateSearch(request)
    }
}
#endif
