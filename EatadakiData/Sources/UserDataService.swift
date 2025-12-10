import EatadakiKit
import Foundation
import GRDB

public class UserDataService {
    
    public let db: DatabaseWriter
    
    public init(
        fileSystemProvider: FileSystemProvider = FileManager.default,
    ) throws {
        let appSupportURL = try fileSystemProvider.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let userDbURL = appSupportURL.appendingPathComponent("user.sqlite")
        db = try DatabasePool(path: userDbURL.path)
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        try migrator.migrate()
    }

}
