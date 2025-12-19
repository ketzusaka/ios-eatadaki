import Foundation
import GRDB

final public class DeviceConfigDatabaseMigrator {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            // Create device configuration table (key-value store)
            try db.create(table: DeviceConfigurationRecord.databaseTableName, ifNotExists: true) { t in
                t.column("key", .text).primaryKey()
                t.column("value", .text).notNull()
            }
        }

        try migrator.migrate(db)
    }
}
