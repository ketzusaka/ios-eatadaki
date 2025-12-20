import EatadakiKit
import Foundation
import GRDB
import os

public protocol ExperiencesDataService {
    var spotsRepository: SpotsRepository { get }
    var experiencesRepository: ExperiencesRepository { get }
}

public class RealExperiencesDataService: ExperiencesDataService {
    public let db: DatabaseWriter

    public lazy var spotsRepository: any SpotsRepository = {
        RealSpotsRepository(db: db)
    }()

    public lazy var experiencesRepository: any ExperiencesRepository = {
        RealExperiencesRepository(db: db)
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

        let experiencesDbURL = appSupportURL.appendingPathComponent("experiences.sqlite")
        Logger.persistence.debug("Experiences Data Service using database at \(experiencesDbURL.path)")
        db = try DatabasePool(path: experiencesDbURL.path)
        let migrator = ExperiencesDatabaseMigrator(db: db)
        try migrator.migrate()
    }
}
