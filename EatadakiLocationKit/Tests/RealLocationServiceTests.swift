import EatadakiData
import EatadakiLocationKit
import Foundation
import Testing

@Suite("RealLocationService Tests")
struct RealLocationServiceTests {
    @Test("obtain throws unconfigured when optInLocationServices is false")
    func testObtainThrowsUnconfiguredWhenNotOptedIn() async throws {
        let fakeController = FakeDeviceConfigurationController {
            $0.stubOptInLocationServices = { false }
        }
        let service = RealLocationService(deviceConfigurationController: fakeController)

        await #expect(throws: LocationServiceError.optedOutOfLocationServices) {
            try await service.obtain()
        }

        #expect(fakeController.invokedCountOptInLocationServices == 1)
    }

    @Test("obtain throws failedToReadOptedIntoLocationServices when controller throws")
    func testObtainThrowsFailedToReadWhenControllerThrows() async throws {
        let fakeController = FakeDeviceConfigurationController {
            $0.stubOptInLocationServices = {
                throw NSError(domain: "TestError", code: 1)
            }
        }
        let service = RealLocationService(deviceConfigurationController: fakeController)

        await #expect(throws: LocationServiceError.failedToReadOptedIntoLocationServices) {
            try await service.obtain()
        }

        #expect(fakeController.invokedCountOptInLocationServices == 1)
    }

    @Test("obtain caches opted in value and does not call controller again")
    func testObtainCachesOptedInValue() async throws {
        let fakeController = FakeDeviceConfigurationController()
        let service = RealLocationService(deviceConfigurationController: fakeController)

        // First call should check the controller
        _ = try? await service.obtain()
        #expect(fakeController.invokedCountOptInLocationServices == 1)

        // Second call should use cached value and not call controller again
        _ = try? await service.obtain()

        #expect(fakeController.invokedCountOptInLocationServices == 1)
    }

    @Test("obtain does not cache false value")
    func testObtainDoesNotCacheFalseValue() async throws {
        let fakeController = FakeDeviceConfigurationController {
            $0.stubOptInLocationServices = { false }
        }
        let service = RealLocationService(deviceConfigurationController: fakeController)

        // First call should throw unconfigured
        await #expect(throws: LocationServiceError.optedOutOfLocationServices) {
            try await service.obtain()
        }

        #expect(fakeController.invokedCountOptInLocationServices == 1)

        // Second call should check controller again (not cached)
        await #expect(throws: LocationServiceError.optedOutOfLocationServices) {
            try await service.obtain()
        }

        #expect(fakeController.invokedCountOptInLocationServices == 2)
    }
}
