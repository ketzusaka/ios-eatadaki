import Foundation

public protocol Pouring {
    func shared<T>(key: String, _ make: () -> T) -> T
}

public extension Pouring {
    func shared<T>(key: String = "\(#file):\(#line)", _ make: () -> T) -> T {
        shared(key: key, make)
    }
}

/// A low-level dependency injection container that caches instances based on keys.
open class Bartender: Pouring {
    private let queue = DispatchQueue(label: "com.aethercodelabs.eatadaki.pour.cache")
    private var storage: [String: Any] = [:]

    /// Initializes a new Bartender instance.
    public init() {}

    /// Retrieves or creates a cached instance of a type.
    ///
    /// - Parameters:
    ///   - key: A unique key for caching. Defaults to a string interpolation of the caller's file and line number.
    ///   - factory: A closure that generates the instance if it's not already cached.
    /// - Returns: The cached or newly created instance.
    public func shared<T>(
        key: String = "\(#file):\(#line)",
        _ factory: () -> T
    ) -> T {
        queue.sync {
            if let cached = storage[key] as? T {
                return cached
            }

            let instance = factory()
            storage[key] = instance
            return instance
        }
    }
}
