import EatadakiData
import Foundation
import Observation

@Observable
public class UserController {
    public private(set) var user: UserRecord?

    private let userRepository: any UserRepository

    public init(userRepository: any UserRepository, user: UserRecord?) {
        self.userRepository = userRepository
        self.user = user
    }

    public init(userRepository: any UserRepository) async throws(UserRepositoryError) {
        self.userRepository = userRepository
        self.user = try await userRepository.fetchUser()
    }
}
