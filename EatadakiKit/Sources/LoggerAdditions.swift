import Foundation
import os

extension Logger {
    
    static let subsystem = Bundle.main.bundleIdentifier!
    
    public static let app = Logger(subsystem: Self.subsystem, category: "App")
    public static let spots = Logger(subsystem: Self.subsystem, category: "Spots")
    public static let persistence = Logger(subsystem: Self.subsystem, category: "Persistence")
    public static let sync = Logger(subsystem: Self.subsystem, category: "Sync")
    public static let view = Logger(subsystem: Self.subsystem, category: "View")
    
    public init<T>(for type: T) {
        self.init(subsystem: Self.subsystem, category: String(describing: type))
    }
    
}
