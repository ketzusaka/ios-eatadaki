#if DEBUG
import Foundation

public class FakeDeviceConfigurationController: DeviceConfigurationController {
    
    public init(_ configure: (FakeDeviceConfigurationController) -> Void = { _ in }) {
        configure(self)
    }
    
    public private(set) var invokedCountOptInLocationServices: Int = 0
    public var stubOptInLocationServices: Bool = false
    
    public var optInLocationServices: Bool {
        get async throws {
            invokedCountOptInLocationServices += 1
            return stubOptInLocationServices
        }
    }
    
    public private(set) var invocationsSetOptInLocationServices: [Bool] = []
    public var stubSetOptInLocationServices: (Bool) async throws -> Void = { _ in }
    
    public func setOptInLocationServices(_ optInLocationServices: Bool) async throws {
        invocationsSetOptInLocationServices.append(optInLocationServices)
        try await stubSetOptInLocationServices(optInLocationServices)
    }
    
    public private(set) var invokedCountReset: Int = 0
    public var stubReset: () async throws -> Void = { }
    
    public func reset() async throws {
        invokedCountReset += 1
        try await stubReset()
    }
}
#endif
