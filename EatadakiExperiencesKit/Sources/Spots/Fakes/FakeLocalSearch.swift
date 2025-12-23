#if DEBUG
import MapKit

public class FakeLocalSearch: LocalSearch {
    public init(_ configure: (FakeLocalSearch) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invokedCountSearch: Int = 0
    public var stubSearch: () async throws(LocalSearchError) -> MKLocalSearch.Response = {
        MKLocalSearch.Response()
    }

    public func search() async throws(LocalSearchError) -> MKLocalSearch.Response {
        invokedCountSearch += 1
        return try await stubSearch()
    }
}
#endif
