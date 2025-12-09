import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("DeviceConfigDatabaseMigrator Tests")
struct DeviceConfigDatabaseMigratorTests {
    
    @Test("Migration creates deviceConfiguration table")
    func testMigrationCreatesDeviceConfigurationTable() throws {
        let db = try DatabaseQueue()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        try db.read { database in
            let tableExists = try database.tableExists("deviceConfiguration")
            #expect(tableExists == true)
        }
    }
    
    @Test("DeviceConfiguration table has correct columns")
    func testDeviceConfigurationTableHasCorrectColumns() throws {
        let db = try DatabaseQueue()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(deviceConfiguration)")
            let columnNames = Set(tableInfo.map { $0["name"] as String })
            
            #expect(columnNames.contains("key"))
            #expect(columnNames.contains("value"))
            
            // Check key is primary key
            let keyRow = try #require(tableInfo.first { $0["name"] as String == "key" })
            let keyPk = keyRow["pk"] as? Int64 ?? 0
            #expect(keyPk == 1) // pk = 1 means it's part of primary key
            
            // Check value is not null
            let valueRow = try #require(tableInfo.first { $0["name"] as String == "value" })
            let valueNotNull = valueRow["notnull"] as? Int64 ?? 0
            #expect(valueNotNull == 1) // 1 means NOT NULL
        }
    }
    
    @Test("DeviceConfiguration table accepts text columns")
    func testDeviceConfigurationTableAcceptsTextColumns() throws {
        let db = try DatabaseQueue()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(deviceConfiguration)")
            
            let keyRow = try #require(tableInfo.first { $0["name"] as String == "key" })
            let keyType = try #require(keyRow["type"] as? String)
            #expect(keyType.uppercased() == "TEXT")
            
            let valueRow = try #require(tableInfo.first { $0["name"] as String == "value" })
            let valueType = try #require(valueRow["type"] as? String)
            #expect(valueType.uppercased() == "TEXT")
        }
    }
    
    @Test("Migration is idempotent")
    func testMigrationIsIdempotent() throws {
        let db = try DatabaseQueue()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        
        // Run migration twice
        try migrator.migrate()
        try migrator.migrate()
        
        // Should still work and table should exist
        try db.read { database in
            let tableExists = try database.tableExists("deviceConfiguration")
            #expect(tableExists == true)
        }
    }
    
    @Test("Can insert and fetch device configuration after migration")
    func testCanInsertAndFetchDeviceConfigurationAfterMigration() throws {
        let db = try DatabaseQueue()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        let testConfig = DeviceConfiguration(key: "testKey", value: "testValue")
        
        try db.write { database in
            try testConfig.insert(database)
        }
        
        try db.read { database in
            let fetchedConfig = try #require(try? DeviceConfiguration.fetchOne(database, key: "testKey"))
            #expect(fetchedConfig.key == testConfig.key)
            #expect(fetchedConfig.value == testConfig.value)
        }
    }
}
