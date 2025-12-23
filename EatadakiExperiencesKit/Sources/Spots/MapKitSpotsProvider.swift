import MapKit

public class MapKitSpotsProvider: SpotsProvider {
    private let requestProvider: LocalSearchRequestProvider
    private let regionProvider: LocalSearchRegionProvider

    public init(
        requestProvider: LocalSearchRequestProvider,
        regionProvider: LocalSearchRegionProvider
    ) {
        self.requestProvider = requestProvider
        self.regionProvider = regionProvider
    }

    public func findSpots(request: FindSpotsRequest) async throws(SpotsSearcherError) -> FindSpotsResponse {
        let search: any LocalSearch

        if let query = request.query {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = query
            if let location = request.location {
                searchRequest.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01),
                )
            }
            search = requestProvider.createSearch(request: searchRequest)
        } else if let location = request.location {
            let searchRequest = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 500)
            searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(
                including: [
                    .airport,
                    .amusementPark,
                    .bakery,
                    .brewery,
                    .cafe,
                    .distillery,
                    .foodMarket,
                    .movieTheater,
                    .musicVenue,
                    .nightlife,
                    .restaurant,
                    .theater,
                    .winery,
                ]
            )
            search = regionProvider.createSearch(request: searchRequest)
        } else {
            throw SpotsSearcherError.invalidRequest("A query or location is required.")
        }

        do {
            let result = try await search.search()
            let mapItems = result.mapItems
            var spots = [FoundSpot]()
            for mapItem in mapItems {
                guard let id = mapItem.identifier?.rawValue else {
                    continue
                }
                guard let name = mapItem.name else {
                    continue
                }

                let spot = FoundSpot(
                    id: UUID(),
                    mapkitId: id,
                    name: name,
                    latitude: mapItem.location.coordinate.latitude,
                    longitude: mapItem.location.coordinate.longitude,
                )

                spots.append(spot)
            }

            return FindSpotsResponse(spots: spots)
        } catch {
            switch error {
            case .providerError(let message):
                throw SpotsSearcherError.providerError(message)
            }
        }
    }
}
