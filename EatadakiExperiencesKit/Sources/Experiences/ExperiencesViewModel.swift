import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import Foundation
import Observation

public typealias ExperiencesViewModelDependencies = LocationServiceProviding & DeviceConfigurationControllerProviding & ExperiencesRepositoryProviding

@Observable
@MainActor
public final class ExperiencesViewModel {
    public struct Experience: Identifiable {
        public let backingData: ExperienceInfoSummary

        public var id: UUID { backingData.experience.id }
        public var name: String { backingData.experience.name }

        public init(from experienceSummary: ExperienceInfoSummary) {
            self.backingData = experienceSummary
        }
    }

    public enum Stage {
        case uninitialized // App hasn't called `initialize()`
        case initializing // Checking opt-in status
        case ready // Ready to display content
    }

    public var stage: Stage = .uninitialized
    public var experiences: [Experience] = []
    public var isOptedIntoLocationServices: Bool = false
    public var searchQuery: String = "" {
        didSet {
            observeExperiences()
        }
    }

    private let dependencies: ExperiencesViewModelDependencies
    private var observationTask: Task<Void, any Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    public init(
        dependencies: ExperiencesViewModelDependencies,
    ) {
        self.dependencies = dependencies
    }

    public func initialize() async {
        stage = .initializing

        // Check opt-in status
        let isOptedIn: Bool
        do {
            isOptedIn = try await dependencies.deviceConfigurationController.optInLocationServices
        } catch {
            isOptedIn = false
        }

        isOptedIntoLocationServices = isOptedIn
        observeExperiences()
        stage = .ready
    }

    // Refreshes our data observer. Should be called on init or search query change
    private func observeExperiences() {
        let request = experiencesDataRequest
        observationTask = Task { [weak self] in
            guard let observation = await self?.dependencies.experiencesRepository.observeExperiences(request: request) else {
                return
            }
            for try await experienceSummaries in observation {
                guard !Task.isCancelled else { return }
                guard let self else { return }
                let listableExperiences = experienceSummaries.map(Experience.init(from:))
                await self.updateExperiences(with: listableExperiences)
            }
        }
    }

    private func updateExperiences(with experiences: [Experience]) async {
        self.experiences = experiences
    }

    private var experiencesDataRequest: FetchExperiencesDataRequest {
        // TODO: Add search query filtering when FetchExperiencesDataRequest supports it
        FetchExperiencesDataRequest()
    }
}

#if DEBUG
public struct FakeExperiencesViewModelDependencies: DeviceConfigurationControllerProviding, ExperiencesRepositoryProviding, SpotsRepositoryProviding, LocationServiceProviding {
    public var fakeExperiencesRepository = FakeExperiencesRepository()
    public var experiencesRepository: any ExperiencesRepository { fakeExperiencesRepository }

    public var fakeLocationService = FakeLocationService()
    public var locationService: LocationService { fakeLocationService }

    public var fakeDeviceConfigurationController = FakeDeviceConfigurationController()
    public var deviceConfigurationController: DeviceConfigurationController { fakeDeviceConfigurationController }

    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: any SpotsRepository { fakeSpotsRepository }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
