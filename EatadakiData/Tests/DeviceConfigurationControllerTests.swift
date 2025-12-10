import EatadakiData
import Foundation
import GRDB
import Testing

@Suite("RealDeviceConfigurationController Tests")
struct DeviceConfigurationControllerTests {
    
    @Test("optInLocationServices returns false by default")
    func testOptInLocationServicesReturnsFalseByDefault() async throws {
        let controller = try setupController()
        
        let value = try await controller.optInLocationServices
        
        #expect(value == false)
    }
    
    @Test("setOptInLocationServices sets value to true")
    func testSetOptInLocationServicesToTrue() async throws {
        let controller = try setupController()
        
        try await controller.setOptInLocationServices(true)
        let value = try await controller.optInLocationServices
        
        #expect(value == true)
    }
    
    @Test("setOptInLocationServices sets value to false")
    func testSetOptInLocationServicesToFalse() async throws {
        let controller = try setupController()
        
        try await controller.setOptInLocationServices(true)
        try await controller.setOptInLocationServices(false)
        let value = try await controller.optInLocationServices
        
        #expect(value == false)
    }
    
    @Test("setOptInLocationServices persists value")
    func testSetOptInLocationServicesPersistsValue() async throws {
        let db = try createInMemoryDatabase()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        try migrator.migrate()
        
        let controller1 = RealDeviceConfigurationController(db: db)
        try await controller1.setOptInLocationServices(true)
        
        // Create a new controller instance with the same database
        let controller2 = RealDeviceConfigurationController(db: db)
        let value = try await controller2.optInLocationServices
        
        #expect(value == true)
    }
    
    @Test("optInLocationServices can be toggled multiple times")
    func testOptInLocationServicesCanBeToggledMultipleTimes() async throws {
        let controller = try setupController()
        
        try await controller.setOptInLocationServices(true)
        #expect(try await controller.optInLocationServices == true)
        
        try await controller.setOptInLocationServices(false)
        #expect(try await controller.optInLocationServices == false)
        
        try await controller.setOptInLocationServices(true)
        #expect(try await controller.optInLocationServices == true)
        
        try await controller.setOptInLocationServices(false)
        #expect(try await controller.optInLocationServices == false)
    }
    
    // MARK: - Helpers
    
    private func createInMemoryDatabase() throws -> DatabaseQueue {
        try DatabaseQueue()
    }
    
    private func setupController() throws -> RealDeviceConfigurationController {
        let db = try createInMemoryDatabase()
        let migrator = DeviceConfigDatabaseMigrator(db: db)
        try migrator.migrate()
        return RealDeviceConfigurationController(db: db)
    }
}
