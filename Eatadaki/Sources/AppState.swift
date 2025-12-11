import Foundation

enum AppState {
    case uninitialized
    case initializing
    case initializationFailure(String)
    case initialized(InitializedContext)
}
