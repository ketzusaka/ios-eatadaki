import Foundation
import GRDB

final public class UserDatabaseMigrator {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            // Create user table
            try db.create(table: UserRecord.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("email", .text).notNull()
                t.column("createdAt", .datetime).notNull()
            }
        }

        try migrator.migrate(db)
    }
}
