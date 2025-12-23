import Foundation
import GRDB

public struct SpotInfoSummary: FetchableRecord, Decodable, Sendable, Hashable {
    public var spot: SpotRecord

    public init(
        spot: SpotRecord,
    ) {
        self.spot = spot
    }

    public init(row: Row) throws {
        spot = try SpotRecord(row: row)
    }
}
