import MapKit

public class MapKitLocalSearchRegionProvider: LocalSearchRegionProvider {
    public init() {}

    public func createSearch(request: MKLocalPointsOfInterestRequest) -> any LocalSearch {
        MKLocalSearch(request: request)
    }
}
