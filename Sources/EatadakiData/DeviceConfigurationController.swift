import Foundation
import GRDB

public protocol DeviceConfigurationController: AnyObject {
    var optInLocationServices: Bool { get async throws }
    func setOptInLocationServices(_ optInLocationServices: Bool) async throws
    
    func reset() async throws
}

public protocol DeviceConfigurationControllerProviding {
    var deviceConfigurationController: DeviceConfigurationController { get }
}

public actor RealDeviceConfigurationController: DeviceConfigurationController {
    
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }
    
    public var optInLocationServices: Bool {
        get async throws {
            try await db.read { db in
                try Bool(DeviceConfiguration.fetchOne(db, key: "optInLocationServices")?.value ?? "false") ?? false
            }
        }
    }
    
    public func setOptInLocationServices(_ optInLocationServices: Bool) async throws {
        try await db.write { db in
            let config = DeviceConfiguration(key: "optInLocationServices", value: optInLocationServices ? "1" : "0")
            try config.save(db)
        }
    }
    
    public func reset() async throws {
        fatalError("TBD")
    }

}

