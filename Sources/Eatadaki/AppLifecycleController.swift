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
            // Create separate database connections for each domain
            let userDbURL = try getDatabaseURL(name: "user")
            let userDb = try DatabasePool(path: userDbURL.path)
            
            let deviceConfigDbURL = try getDatabaseURL(name: "device_config")
            let deviceConfigDb = try DatabasePool(path: deviceConfigDbURL.path)
            
            let experiencesDbURL = try getDatabaseURL(name: "experiences")
            let experiencesDb = try DatabasePool(path: experiencesDbURL.path)

            // Run migrations
            let userMigrator = UserDatabaseMigrator(db: userDb)
            try userMigrator.migrate()
            
            let deviceConfigMigrator = DeviceConfigDatabaseMigrator(db: deviceConfigDb)
            try deviceConfigMigrator.migrate()
            
            let experiencesMigrator = ExperiencesDatabaseMigrator(db: experiencesDb)
            try experiencesMigrator.migrate()

            let dependencies = InitializedDependencies(
                experiencesDb: experiencesDb,
                deviceConfigDb: deviceConfigDb,
                userDb: userDb,
            )

            let context = InitializedContext(dependencies: dependencies)

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
            if let user = try await context.dependencies.userRepository.fetchUser() {
                let userController = UserController(userRepository: context.dependencies.userRepository, user: user)
                state = .authenticated(context, userController)
            } else {
                state = .unauthenticated(context)
            }
        } catch {
            state = .unauthenticated(context)
        }
    }

    private func getDatabaseURL(name: String) throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupportURL.appendingPathComponent("\(name).sqlite")
    }
}
