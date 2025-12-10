import EatadakiData
import EatadakiKit
import EatadakiUI
import EatadakiLocationKit
import GRDB
import Pour

public class InitializedContext: Bartender {

    public let experiencesDataService: ExperiencesDataService
    public let deviceConfigDataService: DeviceConfigDataService
    public let userDataService: UserDataService

    public init(
        experiencesDataService: ExperiencesDataService,
        deviceConfigDataService: DeviceConfigDataService,
        userDataService: UserDataService,
    ) {
        self.experiencesDataService = experiencesDataService
        self.deviceConfigDataService = deviceConfigDataService
        self.userDataService = userDataService
    }

}

// Conform to our dependencies so we automatically get the providers we need
extension InitializedContext: DeviceConfigurationControllerDependencies & DeviceConfigurationControllerProviding {}
extension InitializedContext: LocationServiceDependencies & LocationServiceProviding {}
extension InitializedContext: SpotsRepositoryDependencies & SpotsRepositoryProviding {}
extension InitializedContext: UserRepositoryDependencies & UserRepositoryProviding {}

