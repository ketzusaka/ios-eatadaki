import Foundation
import GRDB

final public class EatadakiDatabaseMigrator {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createUser") { db in
            try db.create(table: User.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("email", .text).notNull()
                t.column("createdAt", .datetime).notNull()
            }
        }

        migrator.registerMigration("createSpots") { db in
            try db.create(table: Spot.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("mapkitId", .text)
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE UNIQUE INDEX IF NOT EXISTS spots_mapkitId_unique ON spots(mapkitId) WHERE mapkitId IS NOT NULL")
        }

        try migrator.migrate(db)
    }
}
