import EatadakiData
import Foundation
import Observation

public typealias AddExperienceViewModelDependencies = ExperiencesRepositoryProviding

public enum AddExperienceViewModelError: Error, Equatable {
    case unableToAdd
}

@Observable
@MainActor
public final class AddExperienceViewModel {
    private let dependencies: AddExperienceViewModelDependencies
    private let spotId: UUID

    public var name = ""
    public var description = ""
    public var showAddRating = false
    public var experienceRating = 6
    public var experienceNote = ""

    public var isValid: Bool {
        !name.isEmpty
    }

    public init(
        dependencies: AddExperienceViewModelDependencies,
        spotId: UUID,
    ) {
        self.dependencies = dependencies
        self.spotId = spotId
    }

    public func saveExperience() async {
        do {
            _ = try await dependencies.experiencesRepository.createExperience(
                spotId: spotId,
                name: name,
                description: description,
                rating: CreateRating(
                    spotId: spotId,
                    rating: experienceRating,
                    note: experienceNote.nilIfEmpty,
                ),
            )

            // TODO: Communicate back to the creator somehow that the experience was created so it can push into it.
        } catch {
            // TODO: Handle errors
        }
    }
}

#if DEBUG
public struct FakeAddExperienceViewModelDependencies: ExperiencesRepositoryProviding {
    public var fakeExperiencesRepository = FakeExperiencesRepository()
    public var experiencesRepository: any ExperiencesRepository { fakeExperiencesRepository }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
