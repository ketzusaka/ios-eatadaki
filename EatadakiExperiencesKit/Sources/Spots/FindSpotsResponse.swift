public struct FindSpotsResponse {
    public var spots: [FoundSpot]

    public init(spots: [FoundSpot] = []) {
        self.spots = spots
    }
}
