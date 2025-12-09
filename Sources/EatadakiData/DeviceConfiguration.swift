import Foundation
import GRDB

public struct DeviceConfiguration: Codable {
    
    // TODO: Make Key an Enum
    public var key: String
    public var value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

extension DeviceConfiguration: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String { "deviceConfiguration" }
}

