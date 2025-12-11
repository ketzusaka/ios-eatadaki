#if DEBUG
import Foundation

public class FakeDeviceConfigurationController: DeviceConfigurationController {
    public init(_ configure: (FakeDeviceConfigurationController) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invokedCountOptInLocationServices: Int = 0
    public var stubOptInLocationServices: () async throws(DeviceConfigurationControllerError) -> Bool = { true }

    public var optInLocationServices: Bool {
        get async throws(DeviceConfigurationControllerError) {
            invokedCountOptInLocationServices += 1
            return try await stubOptInLocationServices()
        }
    }

    public private(set) var invocationsSetOptInLocationServices: [Bool] = []
    public var stubSetOptInLocationServices: (Bool) async throws(DeviceConfigurationControllerError) -> Void = { _ in }

    public func setOptInLocationServices(_ optInLocationServices: Bool) async throws(DeviceConfigurationControllerError) {
        invocationsSetOptInLocationServices.append(optInLocationServices)
        try await stubSetOptInLocationServices(optInLocationServices)
    }

    public private(set) var invokedCountReset: Int = 0
    public var stubReset: () async throws(DeviceConfigurationControllerError) -> Void = { }

    public func reset() async throws(DeviceConfigurationControllerError) {
        invokedCountReset += 1
        try await stubReset()
    }
}
#endif
