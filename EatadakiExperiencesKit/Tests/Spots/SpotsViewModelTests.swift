import CoreLocation
import EatadakiData
import EatadakiExperiencesKit
import EatadakiLocationKit
import Foundation
import Testing

@MainActor
@Suite("SpotsViewModel Tests")
struct SpotsViewModelTests {
    @Test("initial state has uninitialized stage and empty spots")
    func testInitialState() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let viewModel = SpotsViewModel(dependencies: dependencies)

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.spots.isEmpty == true)
        #expect(viewModel.currentLocation == nil)
        #expect(viewModel.hasReceivedContent == false)
    }

    @Test("initialize sets stage to requiresOptIn when not opted in")
    func testInitializeSetsStageToRequiresOptIn() async {
        let dependencies = FakeSpotsViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { false }
        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.stage == .requiresOptIn)
        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
    }

    @Test("initialize sets stage to requiresOptIn when controller throws error")
    func testInitializeSetsStageToRequiresOptInWhenControllerThrows() async {
        let dependencies = FakeSpotsViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            throw DeviceConfigurationControllerError.databaseError("Test error")
        }
        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.stage == .requiresOptIn)
        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
    }

    @Test("initialize calls location service and spots searcher when opted in")
    func testInitializeCallsLocationServiceAndSpotsSearcherWhenOptedIn() async {
        let dependencies = FakeSpotsViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { true }
        let testLocation = CLLocation(latitude: 37.7850, longitude: -122.4294)
        dependencies.fakeLocationService.stubObtain = { testLocation }
        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.stage == .fetched)
        #expect(viewModel.currentLocation?.coordinate.latitude == testLocation.coordinate.latitude)
        #expect(viewModel.currentLocation?.coordinate.longitude == testLocation.coordinate.longitude)
        #expect(dependencies.fakeLocationService.invokedCountObtain == 1)
        #expect(dependencies.fakeSpotsSearcher.invocationsFindAndCacheSpots.count == 1)
    }

    @Test("optIntoLocationServices sets opt-in and refreshes location and spots")
    func testOptIntoLocationServices() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let testLocation = CLLocation(latitude: 37.7850, longitude: -122.4294)
        dependencies.fakeLocationService.stubObtain = { testLocation }
        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.optIntoLocationServices()

        #expect(dependencies.fakeDeviceConfigurationController.invocationsSetOptInLocationServices.count == 1)
        #expect(dependencies.fakeDeviceConfigurationController.invocationsSetOptInLocationServices.first == true)
        #expect(dependencies.fakeLocationService.invokedCountObtain == 1)
        #expect(dependencies.fakeSpotsSearcher.invocationsFindAndCacheSpots.count == 1)
    }

    @Test("refreshCurrentLocation updates currentLocation and stage")
    func testRefreshCurrentLocation() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let testLocation = CLLocation(latitude: 37.7850, longitude: -122.4294)
        dependencies.fakeLocationService.stubObtain = { testLocation }
        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.refreshCurrentLocation()

        #expect(viewModel.stage == .located)
        #expect(viewModel.currentLocation?.coordinate.latitude == testLocation.coordinate.latitude)
        #expect(viewModel.currentLocation?.coordinate.longitude == testLocation.coordinate.longitude)
        #expect(dependencies.fakeLocationService.invokedCountObtain == 1)
    }

    @Test("refreshSpots updates stage and hasReceivedContent")
    func testRefreshSpots() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let testLocation = CLLocation(latitude: 37.7850, longitude: -122.4294)
        dependencies.fakeLocationService.stubObtain = { testLocation }
        let viewModel = SpotsViewModel(dependencies: dependencies)
        viewModel.currentLocation = testLocation

        await viewModel.refreshSpots()

        #expect(viewModel.stage == .fetched)
        #expect(viewModel.hasReceivedContent == true)
        #expect(dependencies.fakeSpotsSearcher.invocationsFindAndCacheSpots.count == 1)
    }

    @Test("refreshSpots uses currentLocation in request")
    func testRefreshSpotsUsesCurrentLocation() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let testLocation = CLLocation(latitude: 37.7850, longitude: -122.4294)
        let viewModel = SpotsViewModel(dependencies: dependencies)
        viewModel.currentLocation = testLocation

        await viewModel.refreshSpots()

        let request = dependencies.fakeSpotsSearcher.invocationsFindAndCacheSpots.first
        #expect(request?.location?.coordinate.latitude == testLocation.coordinate.latitude)
        #expect(request?.location?.coordinate.longitude == testLocation.coordinate.longitude)
    }
}
