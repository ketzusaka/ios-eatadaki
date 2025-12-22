import EatadakiData
import SwiftUI

public typealias ExperienceDetailViewModelDependencies = ExperiencesRepositoryProviding

public enum ExperienceDetailViewModelError: Error, Equatable {
    case unableToLoad
}



@Observable
@MainActor
public final class ExperienceDetailViewModel {
    /// The `Experience` data represented within this view model when loaded
    public struct Experience: Identifiable, Equatable, Sendable, ExperienceDetailView.SpotCardViewData, ExperienceDetailView.ExperienceCardViewData {
        public let backingData: ExperienceInfoDetailed

        public var id: UUID { backingData.experience.id }
        public var name: String { backingData.experience.name }
        public var description: String? { backingData.experience.description }
        public var rating: Int? { backingData.experience.rating }
        public var ratingNote: String? { backingData.experience.ratingNote }
        public var spot: SpotRecord { backingData.spot }
        public var ratingHistory: [ExperienceRatingRecord] { backingData.ratingHistory }
        public var spotName: String { backingData.spot.name }
        public var experienceName: String { backingData.experience.name }
        public var experienceDescription: String? { backingData.experience.description }

        public init(from experienceInfo: ExperienceInfoDetailed) {
            self.backingData = experienceInfo
        }
    }

    /// The `Experience` data represented within this view when we have some information, but not all.
    public struct Preview: ExperienceDetailView.SpotCardViewData, ExperienceDetailView.ExperienceCardViewData {
        public var experienceDescription: String?
        public var experienceName: String
        public var rating: Int?
        public var ratingNote: String?
        public var spotName: String
    }

    public enum Stage: Equatable, Sendable {
        case uninitialized // App hasn't called `initialized()`
        case initializing // Reading detail data
        case loaded(Experience) // Fetching finished successfully
        case loadingFailed(ExperienceDetailViewModelError) // Fetching finished unsuccessfully
    }

    let dependencies: ExperienceDetailViewModelDependencies

    public let experienceId: UUID
    public var stage: Stage = .uninitialized

    public var preview: Preview?
    public var experience: Experience? {
        switch stage {
        case .loaded(let experience):
            experience
        default:
            nil
        }
    }

    public var navigationTitle: String {
        experience?.name ?? preview?.experienceName ?? ""
    }

    private var observationTask: Task<Void, any Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    public init(
        dependencies: ExperienceDetailViewModelDependencies,
        experienceSummary: ExperienceInfoSummary,
    ) {
        self.dependencies = dependencies
        self.experienceId = experienceSummary.experience.id
        self.preview = Preview(
            experienceDescription: experienceSummary.experience.description,
            experienceName: experienceSummary.experience.name,
            rating: experienceSummary.experience.rating,
            ratingNote: experienceSummary.experience.ratingNote,
            spotName: experienceSummary.spot.name,
        )
    }

    public init(
        dependencies: ExperienceDetailViewModelDependencies,
        experienceId: UUID,
    ) {
        self.dependencies = dependencies
        self.experienceId = experienceId
    }

    public func initialize() async {
        guard case .uninitialized = stage else { return }
        stage = .initializing
        do {
            let experienceInfoDetailed = try await dependencies.experiencesRepository.fetchExperience(withID: experienceId)
            let experience = Experience(from: experienceInfoDetailed)
            stage = .loaded(experience)
            observeExperienceUpdates()
        } catch {
            stage = .loadingFailed(.unableToLoad)
        }
    }

    private func observeExperienceUpdates() {
        observationTask = Task { [experienceId, weak self] in
            guard let observation = await self?.dependencies.experiencesRepository.observeExperience(withID: experienceId) else {
                return
            }

            do {
                for try await experienceInfoDetailed in observation {
                    guard !Task.isCancelled else { return }
                    guard let self else { return }
                    let experience = Experience(from: experienceInfoDetailed)
                    await self.updateExperience(experience)
                }
            } catch {
                // TODO: Handle error
            }
        }
    }

    private func updateExperience(_ experience: Experience) async {
        stage = .loaded(experience)
    }

    private func updateExperienceNotFound() async {
        stage = .loadingFailed(.unableToLoad)
    }
}

#if DEBUG
public struct FakeExperienceDetailViewModelDependencies: ExperiencesRepositoryProviding {
    public var fakeExperiencesRepository = FakeExperiencesRepository()
    public var experiencesRepository: any ExperiencesRepository { fakeExperiencesRepository }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif

