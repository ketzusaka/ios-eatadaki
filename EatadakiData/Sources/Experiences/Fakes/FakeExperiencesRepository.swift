#if DEBUG
import Foundation

public class FakeExperiencesRepository: ExperiencesRepository {
    public init(_ configure: (FakeExperiencesRepository) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invocationsCreateExperience: [(spotId: UUID, name: String, description: String?, rating: CreateRating?)] = []
    public var stubCreateExperience: (UUID, String, String?, CreateRating?) async throws(ExperiencesRepositoryError) -> ExperienceRecord = { spotId, name, description, rating in
        ExperienceRecord(
            id: UUID(),
            spotId: spotId,
            remoteId: nil,
            name: name,
            description: description,
            rating: rating?.rating,
            ratingNote: rating?.note,
            createdAt: .now,
        )
    }

    public func createExperience(
        spotId: UUID,
        name: String,
        description: String?,
        rating: CreateRating?,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRecord {
        invocationsCreateExperience.append((spotId, name, description, rating))
        return try await stubCreateExperience(spotId, name, description, rating)
    }

    public private(set) var invocationsCreateExperienceRating: [(experienceId: UUID, rating: CreateRating)] = []
    public var stubCreateExperienceRating: (UUID, CreateRating) async throws(ExperiencesRepositoryError) -> ExperienceRatingRecord = { experienceId, rating in
        ExperienceRatingRecord(
            id: UUID(),
            experienceId: experienceId,
            rating: rating.rating,
            notes: rating.note,
            createdAt: .now,
        )
    }

    public func createExperienceRating(
        experienceId: UUID,
        rating: CreateRating,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRatingRecord {
        invocationsCreateExperienceRating.append((experienceId, rating))
        return try await stubCreateExperienceRating(experienceId, rating)
    }

    public private(set) var invocationsFetchExperiences: [FetchExperiencesDataRequest] = []
    public var stubFetchExperiences: (FetchExperiencesDataRequest) async throws(ExperiencesRepositoryError) -> [ExperienceInfoSummary] = { _ in
        []
    }

    public func fetchExperiences(request: FetchExperiencesDataRequest) async throws(ExperiencesRepositoryError) -> [ExperienceInfoSummary] {
        invocationsFetchExperiences.append(request)
        return try await stubFetchExperiences(request)
    }

    public private(set) var invocationsFetchExperienceWithID: [UUID] = []
    public var stubFetchExperienceWithID: (UUID) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed = { id in
        ExperienceInfoDetailed(
            spot: SpotRecord(
                id: UUID(),
                name: "Fake Spot",
                latitude: 37.7850,
                longitude: -122.4294,
                createdAt: .now,
            ),
            experience: ExperienceRecord(
                id: id,
                spotId: UUID(),
                name: "Fake Experience",
                createdAt: .now,
            ),
            ratingHistory: [],
        )
    }

    public func fetchExperience(withID id: UUID) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed {
        invocationsFetchExperienceWithID.append(id)
        return try await stubFetchExperienceWithID(id)
    }

    public private(set) var invocationsObserveExperienceWithID: [UUID] = []
    public var stubObserveExperienceWithID: (UUID) -> any AsyncSequence<ExperienceInfoDetailed, ExperiencesRepositoryError> = { _ in
        FakeAsyncSequence()
    }

    public func observeExperience(withID id: UUID) async -> any AsyncSequence<ExperienceInfoDetailed, ExperiencesRepositoryError> {
        invocationsObserveExperienceWithID.append(id)
        return stubObserveExperienceWithID(id)
    }

    public private(set) var invocationsObserveExperiences: [FetchExperiencesDataRequest] = []
    public var stubObserveExperiences: (FetchExperiencesDataRequest) -> any AsyncSequence<[ExperienceInfoSummary], ExperiencesRepositoryError> = { _ in
        FakeAsyncSequence()
    }

    public func observeExperiences(request: FetchExperiencesDataRequest = .default) async -> any AsyncSequence<[ExperienceInfoSummary], ExperiencesRepositoryError> {
        invocationsObserveExperiences.append(request)
        return stubObserveExperiences(request)
    }
}
#endif
