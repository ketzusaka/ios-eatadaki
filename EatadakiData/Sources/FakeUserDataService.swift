#if DEBUG
import Foundation

public class FakeUserDataService: UserDataService {
    public init(_ configure: (FakeUserDataService) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invokedCountUserRepository: Int = 0
    public var stubUserRepository: UserRepository = FakeUserRepository()

    public var userRepository: UserRepository {
        invokedCountUserRepository += 1
        return stubUserRepository
    }
}
#endif
