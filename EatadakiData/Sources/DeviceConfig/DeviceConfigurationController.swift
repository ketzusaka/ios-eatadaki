import Foundation
import GRDB

public enum DeviceConfigurationControllerError: Error {
    case databaseError(String)
}

public protocol DeviceConfigurationController: AnyObject {
    var optInLocationServices: Bool { get async throws(DeviceConfigurationControllerError) }
    func setOptInLocationServices(_ optInLocationServices: Bool) async throws(DeviceConfigurationControllerError)

    func reset() async throws(DeviceConfigurationControllerError)
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
        get async throws(DeviceConfigurationControllerError) {
            do {
                return try await db.read { db in
                    try Bool(DeviceConfiguration.fetchOne(db, key: DeviceConfigurationKey.optInLocationServices.rawValue)?.value ?? "false") ?? false
                }
            } catch let error as DeviceConfigurationControllerError {
                throw error
            } catch {
                throw DeviceConfigurationControllerError.databaseError(error.localizedDescription)
            }
        }
    }

    public func setOptInLocationServices(_ optInLocationServices: Bool) async throws(DeviceConfigurationControllerError) {
        do {
            try await db.write { db in
                let keyString = DeviceConfigurationKey.optInLocationServices.rawValue
                // Delete existing config if it exists
                _ = try DeviceConfiguration.filter(Column("key") == keyString).deleteAll(db)
                // Insert new config
                let config = DeviceConfiguration(key: .optInLocationServices, value: optInLocationServices ? "true" : "false")
                try config.insert(db)
            }
        } catch let error as DeviceConfigurationControllerError {
            throw error
        } catch {
            throw DeviceConfigurationControllerError.databaseError(error.localizedDescription)
        }
    }

    public func reset() async throws(DeviceConfigurationControllerError) {
        fatalError("TBD")
    }
}
