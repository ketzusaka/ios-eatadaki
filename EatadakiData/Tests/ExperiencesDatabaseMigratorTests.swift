import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("ExperiencesDatabaseMigrator Tests")
struct ExperiencesDatabaseMigratorTests {
    @Test("Migration creates spots table")
    func testMigrationCreatesSpotsTable() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableExists = try database.tableExists("spots")
            #expect(tableExists == true)
        }
    }

    @Test("Migration creates experiences table")
    func testMigrationCreatesExperiencesTable() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableExists = try database.tableExists("experiences")
            #expect(tableExists == true)
        }
    }

    @Test("Migration creates experiences_ratings table")
    func testMigrationCreatesExperiencesRatingsTable() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableExists = try database.tableExists("experiences_ratings")
            #expect(tableExists == true)
        }
    }

    @Test("Spots table has correct columns")
    func testSpotsTableHasCorrectColumns() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(spots)")
            let columnNames = Set(tableInfo.map { $0["name"] as String })

            #expect(columnNames.contains("id"))
            #expect(columnNames.contains("mapkitId"))
            #expect(columnNames.contains("remoteId"))
            #expect(columnNames.contains("name"))
            #expect(columnNames.contains("createdAt"))

            // Check id is primary key
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idPk = idRow["pk"] as? Int64 ?? 0
            #expect(idPk == 1)

            // Check name is not null
            let nameRow = try #require(tableInfo.first { $0["name"] as String == "name" })
            let nameNotNull = nameRow["notnull"] as? Int64 ?? 0
            #expect(nameNotNull == 1)

            // Check createdAt is not null
            let createdAtRow = try #require(tableInfo.first { $0["name"] as String == "createdAt" })
            let createdAtNotNull = createdAtRow["notnull"] as? Int64 ?? 0
            #expect(createdAtNotNull == 1)
        }
    }

    @Test("Experiences table has correct columns")
    func testExperiencesTableHasCorrectColumns() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(experiences)")
            let columnNames = Set(tableInfo.map { $0["name"] as String })

            #expect(columnNames.contains("id"))
            #expect(columnNames.contains("remoteId"))
            #expect(columnNames.contains("name"))
            #expect(columnNames.contains("description"))
            #expect(columnNames.contains("createdAt"))

            // Check id is primary key
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idPk = idRow["pk"] as? Int64 ?? 0
            #expect(idPk == 1)

            // Check name is not null
            let nameRow = try #require(tableInfo.first { $0["name"] as String == "name" })
            let nameNotNull = nameRow["notnull"] as? Int64 ?? 0
            #expect(nameNotNull == 1)

            // Check createdAt is not null
            let createdAtRow = try #require(tableInfo.first { $0["name"] as String == "createdAt" })
            let createdAtNotNull = createdAtRow["notnull"] as? Int64 ?? 0
            #expect(createdAtNotNull == 1)
        }
    }

    @Test("Experiences_ratings table has correct columns")
    func testExperiencesRatingsTableHasCorrectColumns() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(experiences_ratings)")
            let columnNames = Set(tableInfo.map { $0["name"] as String })

            #expect(columnNames.contains("id"))
            #expect(columnNames.contains("experienceId"))
            #expect(columnNames.contains("rating"))
            #expect(columnNames.contains("notes"))
            #expect(columnNames.contains("createdAt"))

            // Check id is primary key
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idPk = idRow["pk"] as? Int64 ?? 0
            #expect(idPk == 1)

            // Check experienceId is not null
            let experienceIdRow = try #require(tableInfo.first { $0["name"] as String == "experienceId" })
            let experienceIdNotNull = experienceIdRow["notnull"] as? Int64 ?? 0
            #expect(experienceIdNotNull == 1)

            // Check rating is not null
            let ratingRow = try #require(tableInfo.first { $0["name"] as String == "rating" })
            let ratingNotNull = ratingRow["notnull"] as? Int64 ?? 0
            #expect(ratingNotNull == 1)

            // Check createdAt is not null
            let createdAtRow = try #require(tableInfo.first { $0["name"] as String == "createdAt" })
            let createdAtNotNull = createdAtRow["notnull"] as? Int64 ?? 0
            #expect(createdAtNotNull == 1)
        }
    }

    @Test("Migration creates indexes")
    func testMigrationCreatesIndexes() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            // Check spots indexes
            let spotsMapkitIdIndex = try Row.fetchOne(database, sql: "SELECT name FROM sqlite_master WHERE type='index' AND name='spots_mapkitId_unique'")
            #expect(spotsMapkitIdIndex != nil)

            let spotsRemoteIdIndex = try Row.fetchOne(database, sql: "SELECT name FROM sqlite_master WHERE type='index' AND name='spots_remoteId'")
            #expect(spotsRemoteIdIndex != nil)

            // Check experiences indexes
            let experiencesRemoteIdIndex = try Row.fetchOne(database, sql: "SELECT name FROM sqlite_master WHERE type='index' AND name='experiences_remoteId'")
            #expect(experiencesRemoteIdIndex != nil)

            // Check experiences_ratings indexes
            let ratingsExperienceIdIndex = try Row.fetchOne(database, sql: "SELECT name FROM sqlite_master WHERE type='index' AND name='experiences_ratings_experienceId'")
            #expect(ratingsExperienceIdIndex != nil)
        }
    }

    @Test("Migration is idempotent")
    func testMigrationIsIdempotent() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        // Run migration twice
        try migrator.migrate()
        try migrator.migrate()

        // Should still work and tables should exist
        try db.read { database in
            let spotsExists = try database.tableExists("spots")
            #expect(spotsExists == true)
            let experiencesExists = try database.tableExists("experiences")
            #expect(experiencesExists == true)
            let ratingsExists = try database.tableExists("experiences_ratings")
            #expect(ratingsExists == true)
        }
    }

    @Test("Can insert and fetch spot after migration")
    func testCanInsertAndFetchSpotAfterMigration() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        let testSpot = Spot(
            id: UUID(),
            mapkitId: "test-mapkit-id",
            remoteId: "test-remote-id",
            name: "Peace Plaza",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now
        )

        try db.write { database in
            try testSpot.insert(database)
        }

        try db.read { database in
            let fetchedSpot = try #require(try? Spot.fetchOne(database, key: testSpot.id))
            #expect(fetchedSpot.id == testSpot.id)
            #expect(fetchedSpot.name == testSpot.name)
            #expect(fetchedSpot.mapkitId == testSpot.mapkitId)
            #expect(fetchedSpot.latitude == testSpot.latitude)
            #expect(fetchedSpot.longitude == testSpot.longitude)
        }
    }

    @Test("Can insert and fetch experience after migration")
    func testCanInsertAndFetchExperienceAfterMigration() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        let testExperience = Experience(
            id: UUID(),
            remoteId: "test-remote-id",
            name: "Test Experience",
            description: "Test Description",
            createdAt: .now
        )

        try db.write { database in
            try testExperience.insert(database)
        }

        try db.read { database in
            let fetchedExperience = try #require(try? Experience.fetchOne(database, key: testExperience.id))
            #expect(fetchedExperience.id == testExperience.id)
            #expect(fetchedExperience.name == testExperience.name)
            #expect(fetchedExperience.description == testExperience.description)
        }
    }

    @Test("Spots table accepts text id column")
    func testSpotsTableAcceptsTextIdColumn() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(spots)")
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idType = try #require(idRow["type"] as? String)
            #expect(idType.uppercased() == "TEXT")
        }
    }

    @Test("Experiences table accepts text id column")
    func testExperiencesTableAcceptsTextIdColumn() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            let tableInfo = try Row.fetchAll(database, sql: "PRAGMA table_info(experiences)")
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idType = try #require(idRow["type"] as? String)
            #expect(idType.uppercased() == "TEXT")
        }
    }
}
