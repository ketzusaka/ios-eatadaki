import Foundation
import GRDB

public class DeviceConfigDataService {
    
    public let db: DatabaseWriter
    
    public init(
        fileManager: FileManager = .default,
    ) throws {
        let appSupportURL = try fileManager.url(
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
