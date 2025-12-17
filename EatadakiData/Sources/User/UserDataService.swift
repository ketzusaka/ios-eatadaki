import EatadakiKit
import Foundation
import GRDB
import os

public protocol UserDataService {
    var userRepository: UserRepository { get }
}

public class RealUserDataService: UserDataService {
    private let db: DatabaseWriter

    public lazy var userRepository: UserRepository = {
        RealUserRepository(db: db)
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

        let userDbURL = appSupportURL.appendingPathComponent("user.sqlite")
        Logger.persistence.debug("User Data Service using database at \(userDbURL.path)")
        db = try DatabasePool(path: userDbURL.path)
        let migrator = UserDatabaseMigrator(db: db)
        try migrator.migrate()
    }
}
