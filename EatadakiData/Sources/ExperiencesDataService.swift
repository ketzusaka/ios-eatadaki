import EatadakiKit
import Foundation
import GRDB

public class ExperiencesDataService {
    
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
        
        let experiencesDbURL = appSupportURL.appendingPathComponent("experiences.sqlite")
        db = try DatabasePool(path: experiencesDbURL.path)
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()
    }

}
