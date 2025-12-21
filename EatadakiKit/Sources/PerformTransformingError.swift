public func perform<Value, Failure: Error>(
    _ handler: () async throws -> Value,
    transformError: @escaping (Error) -> Failure,
) async throws(Failure) -> Value {
    do {
        return try await handler()
    } catch let error as Failure {
        throw error
    } catch {
        throw transformError(error)
    }
}
