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
            #expect(columnNames.contains("latitude"))
            #expect(columnNames.contains("longitude"))
            #expect(columnNames.contains("createdAt"))
            #expect(columnNames.contains("reason"))

            // Check id is primary key
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idPk = idRow["pk"] as? Int64 ?? 0
            #expect(idPk == 1)

            // Check name is not null
            let nameRow = try #require(tableInfo.first { $0["name"] as String == "name" })
            let nameNotNull = nameRow["notnull"] as? Int64 ?? 0
            #expect(nameNotNull == 1)

            // Check latitude is not null
            let latitudeRow = try #require(tableInfo.first { $0["name"] as String == "latitude" })
            let latitudeNotNull = latitudeRow["notnull"] as? Int64 ?? 0
            #expect(latitudeNotNull == 1)

            // Check longitude is not null
            let longitudeRow = try #require(tableInfo.first { $0["name"] as String == "longitude" })
            let longitudeNotNull = longitudeRow["notnull"] as? Int64 ?? 0
            #expect(longitudeNotNull == 1)

            // Check createdAt is not null
            let createdAtRow = try #require(tableInfo.first { $0["name"] as String == "createdAt" })
            let createdAtNotNull = createdAtRow["notnull"] as? Int64 ?? 0
            #expect(createdAtNotNull == 1)

            // Check reason is not null
            let reasonRow = try #require(tableInfo.first { $0["name"] as String == "reason" })
            let reasonNotNull = reasonRow["notnull"] as? Int64 ?? 0
            #expect(reasonNotNull == 1)
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
            #expect(columnNames.contains("spotId"))
            #expect(columnNames.contains("remoteId"))
            #expect(columnNames.contains("name"))
            #expect(columnNames.contains("description"))
            #expect(columnNames.contains("createdAt"))

            // Check id is primary key
            let idRow = try #require(tableInfo.first { $0["name"] as String == "id" })
            let idPk = idRow["pk"] as? Int64 ?? 0
            #expect(idPk == 1)

            // Check spotId is not null
            let spotIdRow = try #require(tableInfo.first { $0["name"] as String == "spotId" })
            let spotIdNotNull = spotIdRow["notnull"] as? Int64 ?? 0
            #expect(spotIdNotNull == 1)

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

            let experiencesSpotIdIndex = try Row.fetchOne(database, sql: "SELECT name FROM sqlite_master WHERE type='index' AND name='experiences_spotId'")
            #expect(experiencesSpotIdIndex != nil)

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

        let testSpot = SpotRecord(
            id: UUID(),
            mapkitId: "test-mapkit-id",
            remoteId: "test-remote-id",
            name: "Peace Plaza",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
            reason: .findResult,
        )

        try db.write { database in
            try testSpot.insert(database)
        }

        try db.read { database in
            let fetchedSpot = try #require(try? SpotRecord.fetchOne(database, key: testSpot.id))
            #expect(fetchedSpot.id == testSpot.id)
            #expect(fetchedSpot.name == testSpot.name)
            #expect(fetchedSpot.mapkitId == testSpot.mapkitId)
            #expect(fetchedSpot.latitude == testSpot.latitude)
            #expect(fetchedSpot.longitude == testSpot.longitude)
            #expect(fetchedSpot.reason == testSpot.reason)
        }
    }

    @Test("Can insert and fetch experience after migration")
    func testCanInsertAndFetchExperienceAfterMigration() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        let testSpot = SpotRecord(
            id: UUID(),
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
            reason: .findResult,
        )

        let testExperience = ExperienceRecord(
            id: UUID(),
            spotId: testSpot.id,
            remoteId: "test-remote-id",
            name: "Test Experience",
            description: "Test Description",
            createdAt: .now,
        )

        try db.write { database in
            try testSpot.insert(database)
            try testExperience.insert(database)
        }

        try db.read { database in
            let fetchedExperience = try #require(try? ExperienceRecord.fetchOne(database, key: testExperience.id))
            #expect(fetchedExperience.id == testExperience.id)
            #expect(fetchedExperience.spotId == testExperience.spotId)
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

    @Test("Migration creates spots_geospatial_index R-tree table")
    func testMigrationCreatesSpotsGeospatialIndexTable() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            // Check that the virtual table exists
            let rtreeTable = try Row.fetchOne(
                database,
                sql: "SELECT name FROM sqlite_master WHERE type='table' AND name='spots_geospatial_index'"
            )
            #expect(rtreeTable != nil)

            // Verify it's a virtual table
            let tableInfo = try Row.fetchOne(
                database,
                sql: "SELECT sql FROM sqlite_master WHERE type='table' AND name='spots_geospatial_index'"
            )
            let sql = try #require(tableInfo?["sql"] as? String)
            #expect(sql.contains("rtree"))
            #expect(sql.contains("spots_geospatial_index"))
        }
    }

    @Test("R-tree table has correct structure")
    func testRTreeTableHasCorrectStructure() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        try db.read { database in
            // R-tree tables don't show up in PRAGMA table_info, but we can check the shadow tables
            // The shadow tables are: spots_geospatial_index_node, spots_geospatial_index_rowid, spots_geospatial_index_parent
            let nodeTable = try Row.fetchOne(
                database,
                sql: "SELECT name FROM sqlite_master WHERE type='table' AND name='spots_geospatial_index_node'"
            )
            #expect(nodeTable != nil)

            let rowidTable = try Row.fetchOne(
                database,
                sql: "SELECT name FROM sqlite_master WHERE type='table' AND name='spots_geospatial_index_rowid'"
            )
            #expect(rowidTable != nil)

            // Check that the rowid table has the spotId auxiliary column
            // Note: SQLite R-tree uses generic names like "a0", "a1", etc. for auxiliary columns
            // in the shadow table, but we can still use "spotId" when querying the virtual table
            let rowidTableInfo = try Row.fetchAll(
                database,
                sql: "PRAGMA table_info(spots_geospatial_index_rowid)"
            )
            let columnNames = Set(rowidTableInfo.map { $0["name"] as String })
            #expect(columnNames.contains("rowid"))
            #expect(columnNames.contains("nodeno"))
            // The first auxiliary column is named "a0" in the shadow table
            #expect(columnNames.contains("a0"))
        }
    }

    @Test("Can insert spot into R-tree index")
    func testCanInsertSpotIntoRTreeIndex() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        let testSpot = SpotRecord(
            id: UUID(),
            mapkitId: "test-mapkit-id",
            remoteId: "test-remote-id",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
            reason: .findResult,
        )

        try db.write { database in
            try testSpot.insert(database)
            // Insert into R-tree
            try database.execute(
                sql: """
                    INSERT INTO spots_geospatial_index (id, minX, maxX, minY, maxY, spotId)
                    VALUES (NULL, ?, ?, ?, ?, ?)
                """,
                arguments: [
                    testSpot.longitude,
                    testSpot.longitude,
                    testSpot.latitude,
                    testSpot.latitude,
                    testSpot.id.uuidString,
                ]
            )
        }

        // Verify the entry exists in the R-tree
        let fetchedEntry = try db.read { database in
            try Row.fetchOne(
                database,
                sql: """
                    SELECT spotId, minX, maxX, minY, maxY
                    FROM spots_geospatial_index
                    WHERE spotId = ?
                """,
                arguments: [testSpot.id.uuidString]
            )
        }
        let entry = try #require(fetchedEntry)
        let spotId = try #require(entry["spotId"] as? String)
        #expect(spotId == testSpot.id.uuidString)
        let minX = try #require(entry["minX"] as? Double)
        let maxX = try #require(entry["maxX"] as? Double)
        let minY = try #require(entry["minY"] as? Double)
        let maxY = try #require(entry["maxY"] as? Double)
        // R-tree stores coordinates as 32-bit floats, so we need approximate equality
        let epsilon = 0.0001
        #expect(abs(minX - testSpot.longitude) < epsilon)
        #expect(abs(maxX - testSpot.longitude) < epsilon)
        #expect(abs(minY - testSpot.latitude) < epsilon)
        #expect(abs(maxY - testSpot.latitude) < epsilon)
    }

    @Test("Can query R-tree index for nearby spots")
    func testCanQueryRTreeIndexForNearbySpots() throws {
        let db = try DatabaseQueue()
        let migrator = ExperiencesDatabaseMigrator(db: db)

        try migrator.migrate()

        let centerLat = 37.7849447
        let centerLon = -122.4303306

        // Insert a few spots
        let spots = [
            SpotRecord(
                id: UUID(),
                name: "Spot 1",
                latitude: centerLat,
                longitude: centerLon,
                createdAt: .now,
                reason: .findResult,
            ),
            SpotRecord(
                id: UUID(),
                name: "Spot 2",
                latitude: centerLat + 0.01,
                longitude: centerLon + 0.01,
                createdAt: .now,
                reason: .findResult,
            ),
            SpotRecord(
                id: UUID(),
                name: "Spot 3",
                latitude: centerLat + 1.0,
                longitude: centerLon + 1.0,
                createdAt: .now,
                reason: .findResult,
            ),
        ]

        try db.write { database in
            for spot in spots {
                try spot.insert(database)
                try database.execute(
                    sql: """
                        INSERT INTO spots_geospatial_index (id, minX, maxX, minY, maxY, spotId)
                        VALUES (NULL, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        spot.longitude,
                        spot.longitude,
                        spot.latitude,
                        spot.latitude,
                        spot.id.uuidString,
                    ]
                )
            }
        }

        try db.read { database in
            // Query for spots within a bounding box around the center
            let searchMinLon = centerLon - 0.1
            let searchMaxLon = centerLon + 0.1
            let searchMinLat = centerLat - 0.1
            let searchMaxLat = centerLat + 0.1

            let results = try Row.fetchAll(
                database,
                sql: """
                    SELECT spotId
                    FROM spots_geospatial_index
                    WHERE minX <= ? AND maxX >= ? AND minY <= ? AND maxY >= ?
                """,
                arguments: [searchMaxLon, searchMinLon, searchMaxLat, searchMinLat]
            )

            // Should find at least the first two spots (within 0.1 degrees)
            #expect(results.count >= 2)
            let spotIds = Set(results.map { $0["spotId"] as? String ?? "" })
            #expect(spotIds.contains(spots[0].id.uuidString))
            #expect(spotIds.contains(spots[1].id.uuidString))
        }
    }
}
