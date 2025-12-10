import Foundation
import GRDB

final public class ExperiencesDatabaseMigrator {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            // Create spots table
            try db.create(table: Spot.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("mapkitId", .text)
                t.column("remoteId", .text)
                t.column("name", .text).notNull()
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE UNIQUE INDEX IF NOT EXISTS spots_mapkitId_unique ON spots(mapkitId) WHERE mapkitId IS NOT NULL")
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS spots_remoteId ON spots(remoteId) WHERE remoteId IS NOT NULL")

            // Create experiences table
            try db.create(table: Experience.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("remoteId", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS experiences_remoteId ON experiences(remoteId) WHERE remoteId IS NOT NULL")

            // Create experience ratings table
            try db.execute(sql: """
                CREATE TABLE IF NOT EXISTS experiences_ratings (
                    id TEXT PRIMARY KEY,
                    experienceId TEXT NOT NULL REFERENCES experiences(id) ON DELETE CASCADE,
                    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 10),
                    notes TEXT,
                    createdAt DATETIME NOT NULL
                )
            """)
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS experiences_ratings_experienceId ON experiences_ratings(experienceId)")
        }

        try migrator.migrate(db)
    }
}
