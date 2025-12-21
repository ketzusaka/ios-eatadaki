import EatadakiData
import EatadakiExperiencesKit
import EatadakiKit
import EatadakiLocationKit
import Foundation
import Testing

@MainActor
@Suite("ExperiencesViewModel Tests")
struct ExperiencesViewModelTests {
    @Test("initial state has uninitialized stage and empty experiences")
    func testInitialState() async {
        let dependencies = FakeExperiencesViewModelDependencies()
        let viewModel = ExperiencesViewModel(dependencies: dependencies)

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.experiences.isEmpty == true)
        #expect(viewModel.isOptedIntoLocationServices == false)
    }

    @Test("initialize checks opt-in status and sets isOptedIntoLocationServices")
    func testInitializeChecksOptInStatus() async {
        let dependencies = FakeExperiencesViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { true }
        let viewModel = ExperiencesViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.isOptedIntoLocationServices == true)
        #expect(dependencies.fakeDeviceConfigurationController.invokedCountOptInLocationServices == 1)
        #expect(viewModel.stage == .ready)
    }

    @Test("initialize sets isOptedIntoLocationServices to false when not opted in")
    func testInitializeSetsOptInToFalseWhenNotOptedIn() async {
        let dependencies = FakeExperiencesViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { false }
        let viewModel = ExperiencesViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.isOptedIntoLocationServices == false)
        #expect(viewModel.stage == .ready)
    }

    @Test("initialize sets isOptedIntoLocationServices to false when controller throws error")
    func testInitializeHandlesOptInError() async {
        let dependencies = FakeExperiencesViewModelDependencies()
        dependencies.fakeDeviceConfigurationController.stubOptInLocationServices = { () async throws(DeviceConfigurationControllerError) -> Bool in
            throw DeviceConfigurationControllerError.databaseError("Test error")
        }
        let viewModel = ExperiencesViewModel(dependencies: dependencies)

        await viewModel.initialize()

        #expect(viewModel.isOptedIntoLocationServices == false)
        #expect(viewModel.stage == .ready)
    }

    @Test("initialize starts observing experiences")
    func testInitializeStartsObservingExperiences() async {
        let dependencies = FakeExperiencesViewModelDependencies()
        let semaphore = AsyncSemaphore(value: 0)
        dependencies.fakeExperiencesRepository.stubObserveExperiences = { _ in
            Task { await semaphore.signal() }
            return FakeAsyncSequence()
        }
        let viewModel = ExperiencesViewModel(dependencies: dependencies)

        await viewModel.initialize()
        await semaphore.wait()

        #expect(dependencies.fakeExperiencesRepository.invocationsObserveExperiences.count == 1)
    }

    @Test("search query change triggers re-observation")
    func testSearchQueryChangeTriggersReObservation() async {
        let dependencies = FakeExperiencesViewModelDependencies()
        let semaphore = AsyncSemaphore(value: -1)
        dependencies.fakeExperiencesRepository.stubObserveExperiences = { _ in
            Task { await semaphore.signal() }
            return FakeAsyncSequence()
        }
        let viewModel = ExperiencesViewModel(dependencies: dependencies)
        await viewModel.initialize()

        let initialCount = dependencies.fakeExperiencesRepository.invocationsObserveExperiences.count

        viewModel.searchQuery = "test query"
        await semaphore.wait()

        #expect(dependencies.fakeExperiencesRepository.invocationsObserveExperiences.count > initialCount)
    }
}
