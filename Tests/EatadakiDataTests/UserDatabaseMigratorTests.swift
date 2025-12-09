import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("UserDatabaseMigrator Tests")
struct UserDatabaseMigratorTests {
    
    @Test("Migration creates user table")
    func testMigrationCreatesUserTable() throws {
        let db = try createInMemoryDatabase()
        let migrator = UserDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        try db.read { database in
            let tableExists = try database.tableExists("user")
            #expect(tableExists == true)
        }
    }
    
    @Test("User table has correct columns")
    func testUserTableHasCorrectColumns() throws {
        let db = try createInMemoryDatabase()
        let migrator = UserDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        try db.read { database in
            // Use PRAGMA to get table info
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(user)")
            let columnNames = Set(tableInfo.map { $0["name"] as String })
            
            #expect(columnNames.contains("id"))
            #expect(columnNames.contains("email"))
            #expect(columnNames.contains("createdAt"))
            
            // Check id is primary key
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idPk = idRow["pk"] as? Int64 ?? 0
            #expect(idPk == 1) // pk = 1 means it's part of primary key
            
            // Check email is not null
            let emailRow = try #require(tableInfo.first { $0["name"] as String == "email" })
            let emailNotNull = emailRow["notnull"] as? Int64 ?? 0
            #expect(emailNotNull == 1) // 1 means NOT NULL
            
            // Check createdAt is not null
            let createdAtRow = try #require(tableInfo.first { $0["name"] as String == "createdAt" })
            let createdAtNotNull = createdAtRow["notnull"] as? Int64 ?? 0
            #expect(createdAtNotNull == 1) // 1 means NOT NULL
        }
    }
    
    @Test("Migration is idempotent")
    func testMigrationIsIdempotent() throws {
        let db = try createInMemoryDatabase()
        let migrator = UserDatabaseMigrator(db: db)
        
        // Run migration twice
        try migrator.migrate()
        try migrator.migrate()
        
        // Should still work and table should exist
        try db.read { database in
            let tableExists = try database.tableExists("user")
            #expect(tableExists == true)
        }
    }
    
    @Test("Can insert and fetch user after migration")
    func testCanInsertAndFetchUserAfterMigration() throws {
        let db = try createInMemoryDatabase()
        let migrator = UserDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        let testUser = User(
            id: UUID(),
            email: "test@example.com",
            createdAt: Date()
        )
        
        try db.write { database in
            try testUser.insert(database)
        }
        
        try db.read { database in
            let fetchedUser = try #require(try? User.fetchOne(database))
            #expect(fetchedUser.id == testUser.id)
            #expect(fetchedUser.email == testUser.email)
        }
    }
    
    @Test("User table accepts text id column")
    func testUserTableAcceptsTextIdColumn() throws {
        let db = try createInMemoryDatabase()
        let migrator = UserDatabaseMigrator(db: db)
        
        try migrator.migrate()
        
        // Verify id column is text type
        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(user)")
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idType = try #require(idRow["type"] as? String)
            #expect(idType.uppercased() == "TEXT")
        }
    }

    private func createInMemoryDatabase() throws -> DatabaseQueue {
        try DatabaseQueue()
    }

}
