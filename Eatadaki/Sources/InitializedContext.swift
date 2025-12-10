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
extension InitializedContext: DeviceConfigurationControllerProviding {
    public var deviceConfigurationController: DeviceConfigurationController {
        deviceConfigDataService.deviceConfigurationController
    }
}
extension InitializedContext: LocationServiceDependencies & LocationServiceProviding {}
extension InitializedContext: SpotsRepositoryProviding {
    public var spotsRepository: SpotsRepository {
        experiencesDataService.spotsRepository
    }
}
extension InitializedContext: UserRepositoryProviding {
    public var userRepository: UserRepository {
        userDataService.userRepository
    }
}

