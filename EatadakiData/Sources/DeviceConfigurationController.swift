import Foundation
import GRDB
import Pour

public protocol DeviceConfigurationController: AnyObject {
    var optInLocationServices: Bool { get async throws }
    func setOptInLocationServices(_ optInLocationServices: Bool) async throws
    
    func reset() async throws
}

public protocol DeviceConfigurationControllerDependencies {
    var deviceConfigDataService: DeviceConfigDataService { get }
}

public protocol DeviceConfigurationControllerProviding {
    var deviceConfigurationController: DeviceConfigurationController { get }
}

public extension Pouring where Self: DeviceConfigurationControllerDependencies {
    var deviceConfigurationController: DeviceConfigurationController {
        shared {
            RealDeviceConfigurationController(service: deviceConfigDataService)
        }
    }
}

public actor RealDeviceConfigurationController: DeviceConfigurationController {
    
    private let service: DeviceConfigDataService

    public init(service: DeviceConfigDataService) {
        self.service = service
    }
    
    public var optInLocationServices: Bool {
        get async throws {
            try await service.db.read { db in
                try Bool(DeviceConfiguration.fetchOne(db, key: DeviceConfigurationKey.optInLocationServices.rawValue)?.value ?? "false") ?? false
            }
        }
    }
    
    public func setOptInLocationServices(_ optInLocationServices: Bool) async throws {
        try await service.db.write { db in
            let keyString = DeviceConfigurationKey.optInLocationServices.rawValue
            // Delete existing config if it exists
            _ = try DeviceConfiguration.filter(Column("key") == keyString).deleteAll(db)
            // Insert new config
            let config = DeviceConfiguration(key: .optInLocationServices, value: optInLocationServices ? "true" : "false")
            try config.insert(db)
        }
    }
    
    public func reset() async throws {
        fatalError("TBD")
    }

}

