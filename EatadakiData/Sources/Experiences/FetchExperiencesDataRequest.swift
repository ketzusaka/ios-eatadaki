import Foundation

public struct FetchExperiencesDataRequest {
    public var sort: Sort

    public init(sort: Sort = .default) {
        self.sort = sort
    }

    public static var `default`: FetchExperiencesDataRequest {
        FetchExperiencesDataRequest(sort: .default)
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
        case name
    }

    public enum SortDirection {
        case ascending
        case descending
    }
}
