import Foundation

public struct CreateRating: Equatable, Sendable {
    public let spotId: UUID
    public let rating: Int
    public let note: String?

    public init(spotId: UUID, rating: Int, note: String? = nil) {
        self.spotId = spotId
        self.rating = rating
        self.note = note
    }
}
