import CoreLocation
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
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .notDetermined
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

        await #expect(throws: LocationServiceError.optedOutOfLocationServices) {
            try await service.obtain()
        }

        #expect(fakeController.invokedCountOptInLocationServices == 1)
    }

    @Test("obtain throws failedToReadOptedIntoLocationServices when controller throws")
    func testObtainThrowsFailedToReadWhenControllerThrows() async throws {
        let fakeController = FakeDeviceConfigurationController {
            $0.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
                throw DeviceConfigurationControllerError.databaseError("Testing")
            }
        }
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .notDetermined
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

        await #expect(throws: LocationServiceError.failedToReadOptedIntoLocationServices) {
            try await service.obtain()
        }

        #expect(fakeController.invokedCountOptInLocationServices == 1)
    }

    @Test("obtain caches opted in value and does not call controller again")
    func testObtainCachesOptedInValue() async throws {
        let fakeController = FakeDeviceConfigurationController()
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .notDetermined
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

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
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .notDetermined
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

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

    @Test("obtain skips opt-in check when already authorized")
    func testObtainSkipsOptInWhenAuthorized() async throws {
        let fakeController = FakeDeviceConfigurationController()
        let expectedLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .authorizedWhenInUse
            $0.stubRequestLocation = { expectedLocation }
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

        let location = try await service.obtain()

        #expect(location.coordinate.latitude == expectedLocation.coordinate.latitude)
        #expect(location.coordinate.longitude == expectedLocation.coordinate.longitude)
        #expect(fakeController.invokedCountOptInLocationServices == 0)
        #expect(fakeLocationManager.invokedCountRequestLocation == 1)
    }

    @Test("obtain wraps LocationManagerProviderError in updateError")
    func testObtainWrapsLocationManagerProviderError() async throws {
        let fakeController = FakeDeviceConfigurationController()
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .authorizedWhenInUse
            $0.stubRequestLocation = { () async throws(LocationManagerProviderError) -> CLLocation in
                throw LocationManagerProviderError.locationNotDetermined
            }
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

        await #expect(throws: LocationServiceError.updateError(.locationNotDetermined)) {
            try await service.obtain()
        }
    }

    @Test("obtain wraps LocationManagerProviderError liveUpdateError in updateError")
    func testObtainWrapsLocationManagerProviderLiveUpdateError() async throws {
        let fakeController = FakeDeviceConfigurationController()
        let fakeLocationManager = FakeLocationManagerProvider {
            $0.stubAuthorizationStatus = .authorizedWhenInUse
            $0.stubRequestLocation = { () async throws(LocationManagerProviderError) -> CLLocation in
                throw LocationManagerProviderError.liveUpdateError("Test error")
            }
        }
        let service = RealLocationService(
            deviceConfigurationController: fakeController,
            locationManager: fakeLocationManager
        )

        await #expect(throws: LocationServiceError.updateError(.liveUpdateError("Test error"))) {
            try await service.obtain()
        }
    }
}
