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
            // Create database connection
            let dbURL = try getDatabaseURL()
            let db = try DatabasePool(path: dbURL.path)

            // Run migrations
            let userMigrator = UserDatabaseMigrator(db: db)
            try userMigrator.migrate()
            
            let deviceConfigMigrator = DeviceConfigDatabaseMigrator(db: db)
            try deviceConfigMigrator.migrate()
            
            let experiencesMigrator = ExperiencesDatabaseMigrator(db: db)
            try experiencesMigrator.migrate()

            // Create repositories
            let userRepository = RealUserRepository(db: db)
            let spotsRepository = RealSpotsRepository(db: db)
            
            // Create device configuration controller
            let deviceConfigurationController = RealDeviceConfigurationController(db: db)
            
            // Create location service
            let locationService = RealLocationService(deviceConfigurationController: deviceConfigurationController)
            
            let context = InitializedContext(
                userRepository: userRepository,
                spotsRepository: spotsRepository,
                locationService: locationService,
                deviceConfigurationController: deviceConfigurationController,
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

    private func getDatabaseURL() throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupportURL.appendingPathComponent("eatadaki.sqlite")
    }
}
