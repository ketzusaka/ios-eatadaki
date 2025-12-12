import Foundation

public extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for the specified number of seconds.
    ///
    /// - Parameter seconds: The number of seconds to sleep.
    static func sleep(seconds: Double) async throws {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        try await sleep(nanoseconds: nanoseconds)
    }
}
