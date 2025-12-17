import Foundation

struct ErrorTransformingSequence<Element: Sendable, TransformedError: Error>: AsyncSequence {
    typealias AsyncIterator = Iterator
    typealias Failure = TransformedError

    struct Iterator: AsyncIteratorProtocol {
        var baseIterator: AsyncThrowingStream<Element, Error>.AsyncIterator
        let transformError: (Error) -> TransformedError

        mutating func next() async throws(TransformedError) -> Element? {
            do {
                return try await baseIterator.next()
            } catch {
                throw transformError(error)
            }
        }
    }

    let baseStream: any AsyncSequence<Element, Error>
    let transformError: (Error) -> TransformedError

    init(baseStream: any AsyncSequence<Element, Error>, transformError: @escaping (Error) -> TransformedError) {
        self.baseStream = baseStream
        self.transformError = transformError
    }

    func makeAsyncIterator() -> Iterator {
        let iteratorStream = AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await spots in baseStream {
                        continuation.yield(spots)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        return Iterator(
            baseIterator: iteratorStream.makeAsyncIterator(),
            transformError: transformError
        )
    }
}
