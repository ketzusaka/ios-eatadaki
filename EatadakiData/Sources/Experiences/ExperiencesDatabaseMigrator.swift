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
            try db.create(table: SpotRecord.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("mapkitId", .text)
                t.column("remoteId", .text)
                t.column("name", .text).notNull()
                t.column("latitude", .real).notNull()
                t.column("longitude", .real).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("reason", .text).notNull()
            }
            try db.execute(sql: "CREATE UNIQUE INDEX IF NOT EXISTS spots_mapkitId_unique ON spots(mapkitId) WHERE mapkitId IS NOT NULL")
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS spots_remoteId ON spots(remoteId) WHERE remoteId IS NOT NULL")

            // Create experiences table
            try db.create(table: ExperienceRecord.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("spotId", .text).notNull().references(SpotRecord.databaseTableName, onDelete: .cascade)
                t.column("remoteId", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS experiences_remoteId ON experiences(remoteId) WHERE remoteId IS NOT NULL")
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS experiences_spotId ON experiences(spotId)")

            // Create experience ratings table
            try db.create(table: ExperienceRatingRecord.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("experienceId", .text).notNull().references(ExperienceRecord.databaseTableName, onDelete: .cascade)
                t.column("rating", .integer).notNull().check(sql: "rating >= 1 AND rating <= 10")
                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull()
            }
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS experiences_ratings_experienceId ON experiences_ratings(experienceId)")

            // Create R-tree virtual table for geospatial spot searches
            // id: integer primary key (auto-generated)
            // minX, maxX: longitude bounds (same value for points)
            // minY, maxY: latitude bounds (same value for points)
            // +spotId: auxiliary column to store the spot UUID (prefix with + to indicate auxiliary)
            try db.execute(sql: """
                CREATE VIRTUAL TABLE IF NOT EXISTS spots_geospatial_index USING rtree(
                    id,
                    minX, maxX,
                    minY, maxY,
                    +spotId TEXT
                )
            """)
        }

        try migrator.migrate(db)
    }
}
