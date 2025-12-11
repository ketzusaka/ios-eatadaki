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
                try Bool(DeviceConfiguration.fetchOne(db, key: DeviceConfigurationKey.optInLocationServices.rawValue)?.value ?? "false") ?? false
            }
        }
    }

    public func setOptInLocationServices(_ optInLocationServices: Bool) async throws {
        try await db.write { db in
            let keyString = DeviceConfigurationKey.optInLocationServices.rawValue
            // Delete existing config if it exists
            _ = try DeviceConfiguration.filter(Column("key") == keyString).deleteAll(db)
            // Insert new config
            let config = DeviceConfiguration(key: .optInLocationServices, value: optInLocationServices ? "true" : "false")
            try config.insert(db)
        }
    }

    public func reset() async throws {
        fatalError("TBD")
    }
}
