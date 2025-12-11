public extension Optional {
    var unwrapped: Wrapped {
        get throws {
            guard let self else { throw UnwrappingError.empty }
            return self
        }
    }
}

public enum UnwrappingError: Error {
    case empty
}
