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
                t.column("mapkitId", .text)
                t.column("remoteId", .text)
                t.column("name", .text).notNull()
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE UNIQUE INDEX IF NOT EXISTS spots_mapkitId_unique ON spots(mapkitId) WHERE mapkitId IS NOT NULL")
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS spots_remoteId ON spots(remoteId) WHERE remoteId IS NOT NULL")
        }

        migrator.registerMigration("createTastes") { db in
            try db.create(table: Taste.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("remoteId", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS tastes_remoteId ON tastes(remoteId) WHERE remoteId IS NOT NULL")
        }

        migrator.registerMigration("createTasteRatings") { db in
            try db.execute(sql: """
                CREATE TABLE IF NOT EXISTS tastes_ratings (
                    id TEXT PRIMARY KEY,
                    tasteId TEXT NOT NULL REFERENCES tastes(id) ON DELETE CASCADE,
                    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 10),
                    notes TEXT,
                    createdAt DATETIME NOT NULL
                )
            """)
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS tastes_ratings_tasteId ON tastes_ratings(tasteId)")
        }

        try migrator.migrate(db)
    }
}
