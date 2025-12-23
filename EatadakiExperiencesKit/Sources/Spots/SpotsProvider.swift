public protocol SpotsProvider {
    func findSpots(request: FindSpotsRequest) async throws(SpotsSearcherError) -> FindSpotsResponse
}
