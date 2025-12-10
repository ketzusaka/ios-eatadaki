#if DEBUG
import Foundation

public class FakeDeviceConfigDataService: DeviceConfigDataService {
    
    public init(_ configure: (FakeDeviceConfigDataService) -> Void = { _ in }) {
        configure(self)
    }
    
    public private(set) var invokedCountDeviceConfigurationController: Int = 0
    public var stubDeviceConfigurationController: DeviceConfigurationController = FakeDeviceConfigurationController()
    
    public var deviceConfigurationController: DeviceConfigurationController {
        invokedCountDeviceConfigurationController += 1
        return stubDeviceConfigurationController
    }

}
#endif
