import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import EatadakiUI
import GRDB

public class InitializedContext {
    /// Initialization dependencies
    public let deviceConfigDataService: DeviceConfigDataService
    public let experiencesDataService: ExperiencesDataService
    public let userDataService: UserDataService
    
    /// On-the-fly dependencies
    public lazy var locationService: LocationService = {
        RealLocationService(deviceConfigurationController: deviceConfigurationController)
    }()

    public init(
        deviceConfigDataService: DeviceConfigDataService,
        experiencesDataService: ExperiencesDataService,
        userDataService: UserDataService,
    ) {
        self.deviceConfigDataService = deviceConfigDataService
        self.experiencesDataService = experiencesDataService
        self.userDataService = userDataService
    }
}

// Conform to our dependencies so we automatically get the providers we need
extension InitializedContext: DeviceConfigurationControllerProviding {
    public var deviceConfigurationController: DeviceConfigurationController {
        deviceConfigDataService.deviceConfigurationController
    }
}
extension InitializedContext: LocationServiceProviding {}
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
