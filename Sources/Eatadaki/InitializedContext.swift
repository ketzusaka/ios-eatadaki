import EatadakiData
import EatadakiKit
import EatadakiUI

public struct InitializedContext {
    public let userRepository: any UserRepository
    public let spotsRepository: any SpotsRepository
    public let locationService: any LocationService
    public let deviceConfigurationController: any DeviceConfigurationController

    public init(
        userRepository: any UserRepository,
        spotsRepository: any SpotsRepository,
        locationService: any LocationService,
        deviceConfigurationController: any DeviceConfigurationController,
    ) {
        self.userRepository = userRepository
        self.spotsRepository = spotsRepository
        self.locationService = locationService
        self.deviceConfigurationController = deviceConfigurationController
    }
}

extension InitializedContext: DeviceConfigurationControllerProviding {}
extension InitializedContext: LocationServiceProviding {}
extension InitializedContext: SpotsRepositoryProviding {}

// This below isn't great. It's what I want to avoid. Let's find a better solution here.
extension InitializedContext: SpotsViewModelDependencies {}
