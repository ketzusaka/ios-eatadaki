#if DEBUG
import Foundation

public class FakeExperiencesRepository: ExperiencesRepository {
    public init(_ configure: (FakeExperiencesRepository) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsCreateExperience: [(spotId: UUID, name: String, description: String?, rating: CreateRating)] = []
    public var stubCreateExperience: (UUID, String, String?, CreateRating) async throws(ExperiencesRepositoryError) -> ExperienceRecord = { spotId, name, description, _ in
        ExperienceRecord(
            id: UUID(),
            spotId: spotId,
            remoteId: nil,
            name: name,
            description: description,
            createdAt: .now
        )
    }

    public func createExperience(
        spotId: UUID,
        name: String,
        description: String?,
        rating: CreateRating,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRecord {
        invocationsCreateExperience.append((spotId, name, description, rating))
        return try await stubCreateExperience(spotId, name, description, rating)
    }
}
#endif
