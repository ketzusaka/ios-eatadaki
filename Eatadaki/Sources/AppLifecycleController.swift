import EatadakiData
import EatadakiKit
import Foundation
import GRDB
import Observation

@MainActor
@Observable
final class AppLifecycleController {

    private(set) var state: AppState = .uninitialized

    func beginInitializing() async {
        guard case .uninitialized = state else { return }
        state = .initializing

        do {
            // Phase 1: Initialize diagnostics
            // TODO: Implement diagnostics

            // Phase 2: Initialize databases
            let deviceConfigDataService = try DeviceConfigDataService()
            let experiencesDataService = try ExperiencesDataService()
            let userDataService = try UserDataService()
            
            let context = InitializedContext(
                experiencesDataService: experiencesDataService,
                deviceConfigDataService: deviceConfigDataService,
                userDataService: userDataService,
            )

            // Move to initialized state
            state = .initialized(context)

            // Check authentication state
            await checkAuthenticationState(context: context)
        } catch {
            // Handle initialization error
            state = .initializationFailure(error.localizedDescription)
        }
    }

    private func checkAuthenticationState(context: InitializedContext) async {
        do {
            if let user = try await context.userRepository.fetchUser() {
                let userController = UserController(userRepository: context.userRepository, user: user)
                state = .authenticated(context, userController)
            } else {
                state = .unauthenticated(context)
            }
        } catch {
            state = .unauthenticated(context)
        }
    }

}
