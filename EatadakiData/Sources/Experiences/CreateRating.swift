import Foundation

public struct CreateRating: Equatable, Sendable {
    public let rating: Int
    public let note: String?

    public init(rating: Int, note: String? = nil) {
        self.rating = rating
        self.note = note
    }
}
