import EatadakiData
import EatadakiLocationKit
import EatadakiSpotsKit
import Foundation
import Testing

@MainActor
@Suite("SpotsViewModel Tests")
struct SpotsViewModelTests {
    @Test("initial state has empty spots and isOptedIn is false")
    func testInitialState() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let viewModel = SpotsViewModel(dependencies: dependencies)

        #expect(viewModel.spots.isEmpty == true)
        #expect(viewModel.isOptedIn == false)
    }

    @Test("initialize sets isOptedIn to true when controller returns true")
    func testInitializeSetsOptedInToTrue() async {
        let dependencies = FakeSpotsViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { true }
        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.isOptedIn == true)
        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
    }

    @Test("initialize sets isOptedIn to false when controller returns false")
    func testInitializeSetsOptedInToFalse() async {
        let dependencies = FakeSpotsViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { false }

        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.isOptedIn == false)
        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
    }

    @Test("initialize sets isOptedIn to false when controller throws error")
    func testInitializeSetsOptedInToFalseWhenControllerThrows() async {
        let dependencies = FakeSpotsViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            throw DeviceConfigurationControllerError.databaseError("Test error")
        }

        let viewModel = SpotsViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.isOptedIn == false)
        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
    }

    @Test("initialize calls deviceConfigurationController optInLocationServices")
    func testInitializeCallsDeviceConfigurationController() async {
        let dependencies = FakeSpotsViewModelDependencies()
        let viewModel = SpotsViewModel(dependencies: dependencies)

        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 0)

        await viewModel.initialize()

        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
    }
}
