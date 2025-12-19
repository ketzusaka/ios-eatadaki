import Foundation
import GRDB

public enum DeviceConfigurationKey: String, Codable, DatabaseValueConvertible {
    case optInLocationServices

    public var databaseValue: DatabaseValue {
        rawValue.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> DeviceConfigurationKey? {
        guard let string = String.fromDatabaseValue(dbValue) else {
            return nil
        }
        return DeviceConfigurationKey(rawValue: string)
    }
}

public struct DeviceConfigurationRecord: Codable {
    public var key: DeviceConfigurationKey
    public var value: String

    public init(key: DeviceConfigurationKey, value: String) {
        self.key = key
        self.value = value
    }
}

extension DeviceConfigurationRecord: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "deviceConfiguration" }
}
