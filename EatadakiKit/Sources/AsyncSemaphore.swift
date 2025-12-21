import Foundation

/// An actor-based semaphore-like utility for coordinating async operations in tests.
///
/// Similar to `DispatchSemaphore`, but designed for Swift concurrency. Use this to wait for
/// async operations to complete in tests without using `Task.sleep`.
///
/// Example usage:
/// ```swift
/// let semaphore = AsyncSemaphore(value: 0)
///
/// // In test
/// Task {
///     // Perform async work
///     await semaphore.signal()
/// }
///
/// await semaphore.wait() // Waits until count becomes positive, then all waiters are notified
/// ```
public actor AsyncSemaphore {
    private var count: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    /// Creates a new semaphore with the specified initial count.
    ///
    /// - Parameter value: The initial count. Defaults to 0.
    public init(value: Int = 0) {
        self.count = value
    }

    /// Waits until the count becomes positive.
    ///
    /// If the count is already positive, returns immediately.
    /// Otherwise, suspends until `signal()` is called and the count becomes positive.
    /// When the count becomes positive, all waiting tasks are notified at once.
    public func wait() async {
        if count > 0 {
            return
        }

        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    /// Increments the count and notifies all waiters if the count becomes positive.
    ///
    /// If the count becomes positive after incrementing, all waiting tasks are notified at once.
    public func signal() {
        count += 1
        
        if count > 0 && !waiters.isEmpty {
            let allWaiters = waiters
            waiters.removeAll()
            
            for waiter in allWaiters {
                waiter.resume()
            }
        }
    }
}

