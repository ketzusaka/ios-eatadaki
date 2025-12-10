import EatadakiData
import EatadakiKit
import EatadakiUI
import EatadakiLocationKit
import GRDB
import Pour

public struct InitializedContext {
    // This will have a Bartender for dependencies
    // and a Services that holds our services.
    public let dependencies: InitializedDependencies

    public init(dependencies: InitializedDependencies) {
        self.dependencies = dependencies
    }
}

public class InitializedDependencies: Bartender {
    public let experiencesDb: DatabaseWriter
    public let deviceConfigDb: DatabaseWriter
    public let userDb: DatabaseWriter

    public init(experiencesDb: DatabaseWriter, deviceConfigDb: DatabaseWriter, userDb: DatabaseWriter) {
        self.experiencesDb = experiencesDb
        self.deviceConfigDb = deviceConfigDb
        self.userDb = userDb
    }
}

// Conform to our dependencies so we automatically get the providers we need
extension InitializedDependencies: DeviceConfigurationControllerDependencies & DeviceConfigurationControllerProviding {}
extension InitializedDependencies: LocationServiceDependencies & LocationServiceProviding {}
extension InitializedDependencies: SpotsRepositoryDependencies & SpotsRepositoryProviding {}
extension InitializedDependencies: UserRepositoryDependencies & UserRepositoryProviding {}

