#if DEBUG
public struct FakeAsyncSequence<Element, Failure: Error>: AsyncSequence {
    public typealias AsyncIterator = Iterator

    public struct Iterator: AsyncIteratorProtocol {

        var remaining: [Result<Element, Failure>]
        
        public mutating func next() async throws(Failure) -> Element? {
            if remaining.isEmpty {
                nil
            } else {
                try remaining.removeFirst().get()
            }
        }
    }
    
    private let sequence: [Result<Element, Failure>]
    
    public init(sequence: [Element] = []) {
        self.sequence = sequence.map(Result.success)
    }
    
    public init(sequenceResults: [Result<Element, Failure>]) {
        self.sequence = sequenceResults
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(remaining: sequence)
    }
}
#endif
