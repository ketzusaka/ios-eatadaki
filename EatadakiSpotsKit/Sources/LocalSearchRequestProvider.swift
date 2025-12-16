import MapKit

public class MapKitLocalSearchRequestProvider: LocalSearchRequestProvider {
    public init() {}

    public func createSearch(request: MKLocalSearch.Request) -> any LocalSearch {
        MKLocalSearch(request: request)
    }
}
