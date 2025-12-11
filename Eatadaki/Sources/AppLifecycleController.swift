import EatadakiData
import EatadakiKit
import EatadakiUserKit
import Foundation
import GRDB
import Observation

@MainActor
@Observable
final class AppLifecycleController {
    private let fileSystemProvider: FileSystemProvider

    private(set) var state: AppState = .uninitialized

    init(fileSystemProvider: FileSystemProvider = FileManager.default) {
        self.fileSystemProvider = fileSystemProvider
    }

    func beginInitializing() async {
        guard case .uninitialized = state else { return }
        state = .initializing

        do {
            // Phase 1: Initialize diagnostics
            // TODO: Implement diagnostics

            // Phase 2: Initialize databases
            let deviceConfigDataService = try RealDeviceConfigDataService(fileSystemProvider: fileSystemProvider)
            let experiencesDataService = try RealExperiencesDataService(fileSystemProvider: fileSystemProvider)
            let userDataService = try RealUserDataService(fileSystemProvider: fileSystemProvider)
            let userController = try await UserController(userRepository: userDataService.userRepository)

            let context = InitializedContext(
                deviceConfigDataService: deviceConfigDataService,
                experiencesDataService: experiencesDataService,
                userController: userController,
                userDataService: userDataService,
            )

            // Move to initialized state
            state = .initialized(context)
        } catch {
            // Handle initialization error
            state = .initializationFailure(error.localizedDescription)
        }
    }
}
