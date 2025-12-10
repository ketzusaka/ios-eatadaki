import EatadakiKit
import Foundation
import GRDB

public protocol DeviceConfigDataService {
    var deviceConfigurationController: DeviceConfigurationController { get }
}

public class RealDeviceConfigDataService: DeviceConfigDataService {
    
    private let db: DatabaseWriter
    
    public lazy var deviceConfigurationController: DeviceConfigurationController = {
        RealDeviceConfigurationController(db: db)
    }()
    
    public init(
        fileSystemProvider: FileSystemProvider = FileManager.default,
    ) throws {
        let appSupportURL = try fileSystemProvider.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let deviceConfigDbURL = appSupportURL.appendingPathComponent("device_config.sqlite")
        db = try DatabasePool(path: deviceConfigDbURL.path)
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        try migrator.migrate()
    }

}
