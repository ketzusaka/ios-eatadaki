import CoreLocation
import Foundation

public struct FetchSpotsDataRequest {
    public var sort: Sort
    public var query: String?

    public init(sort: Sort = .default, query: String? = nil) {
        self.sort = sort
        self.query = query
    }

    public static var `default`: FetchSpotsDataRequest {
        FetchSpotsDataRequest(sort: .default)
    }

    public struct Sort {
        public var field: SortField
        public var direction: SortDirection

        public init(field: SortField, direction: SortDirection) {
            self.field = field
            self.direction = direction
        }

        public static var `default`: Sort {
            Sort(field: .name, direction: .ascending)
        }
    }

    public enum SortField {
        case distance(from: CLLocationCoordinate2D)
        case name
    }

    public enum SortDirection {
        case ascending
        case descending
    }
}
