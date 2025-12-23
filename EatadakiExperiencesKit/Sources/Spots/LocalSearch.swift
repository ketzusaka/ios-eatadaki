import MapKit

public enum LocalSearchError: Error, Equatable {
    case providerError(String)
}

public protocol LocalSearch: AnyObject {
    func search() async throws(LocalSearchError) -> MKLocalSearch.Response
}

extension MKLocalSearch: LocalSearch {
    public func search() async throws(LocalSearchError) -> MKLocalSearch.Response {
        do {
            return try await start()
        } catch let error as LocalSearchError {
            throw error
        } catch {
            throw LocalSearchError.providerError(error.localizedDescription)
        }
    }
}

public protocol LocalSearchRequestProvider {
    func createSearch(request: MKLocalSearch.Request) -> any LocalSearch
}

public protocol LocalSearchRegionProvider {
    func createSearch(request: MKLocalPointsOfInterestRequest) -> any LocalSearch
}
