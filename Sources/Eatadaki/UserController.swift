import EatadakiData
import Foundation
import Observation

@Observable
final class UserController {
    var user: User

    private let userRepository: any UserRepository

    init(userRepository: any UserRepository, user: User) {
        self.userRepository = userRepository
        self.user = user
    }
}
