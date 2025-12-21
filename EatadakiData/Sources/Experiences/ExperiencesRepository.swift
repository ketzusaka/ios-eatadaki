import EatadakiKit
import Foundation
import GRDB

public enum ExperiencesRepositoryError: Error, Equatable {
    case databaseError(String)
    case spotNotFound
    case experienceNotFound
    case invalidRating
}

public protocol ExperiencesRepository: AnyObject {
    func createExperience(
        spotId: UUID,
        name: String,
        description: String?,
        rating: CreateRating?,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRecord
    
    func createExperienceRating(
        experienceId: UUID,
        rating: CreateRating,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRatingRecord
    
    func fetchExperiences(request: FetchExperiencesDataRequest) async throws(ExperiencesRepositoryError) -> [ExperienceInfoSummary]
    
    func fetchExperience(withID id: UUID) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed
    
    func observeExperience(withID id: UUID) async -> any AsyncSequence<ExperienceInfoDetailed, ExperiencesRepositoryError>
    
    func observeExperiences(request: FetchExperiencesDataRequest) async -> any AsyncSequence<[ExperienceInfoSummary], ExperiencesRepositoryError>
}

public protocol ExperiencesRepositoryProviding {
    var experiencesRepository: ExperiencesRepository { get }
}

public actor RealExperiencesRepository: ExperiencesRepository {
    private let db: DatabaseWriter

    public init(db: DatabaseWriter) {
        self.db = db
    }

    public func createExperience(
        spotId: UUID,
        name: String,
        description: String?,
        rating: CreateRating?,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRecord {
        try await perform {
            try await db.write { db in
                // Verify spot exists
                guard try SpotRecord.filter(Column("id") == spotId).fetchCount(db) > 0 else {
                    throw ExperiencesRepositoryError.spotNotFound
                }

                // Create experience with cached rating if provided
                let experience = ExperienceRecord(
                    id: UUID(),
                    spotId: spotId,
                    remoteId: nil,
                    name: name,
                    description: description,
                    rating: rating?.rating,
                    ratingNote: rating?.note,
                    createdAt: .now,
                )
                try experience.insert(db)

                // Create rating record
                if let rating  {
                    let experienceRating = ExperienceRatingRecord(
                        id: UUID(),
                        experienceId: experience.id,
                        rating: rating.rating,
                        notes: rating.note,
                        createdAt: .now,
                    )
                    try experienceRating.insert(db)
                }

                return experience
            }
        } transformError: { error in
            ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func createExperienceRating(
        experienceId: UUID,
        rating: CreateRating,
    ) async throws(ExperiencesRepositoryError) -> ExperienceRatingRecord {
        try await perform {
            try await db.write { db in
                // Verify experience exists and fetch it
                guard var experience = try ExperienceRecord.fetchOne(db, key: experienceId) else {
                    throw ExperiencesRepositoryError.experienceNotFound
                }

                // Create rating record
                let experienceRating = ExperienceRatingRecord(
                    id: UUID(),
                    experienceId: experienceId,
                    rating: rating.rating,
                    notes: rating.note,
                    createdAt: .now,
                )
                try experienceRating.insert(db)

                // Update cached rating fields on experience
                experience.rating = rating.rating
                experience.ratingNote = rating.note
                try experience.update(db)

                return experienceRating
            }
        } transformError: { error in
            ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchExperiences(request: FetchExperiencesDataRequest = .default) async throws(ExperiencesRepositoryError) -> [ExperienceInfoSummary] {
        try await perform {
            try await db.read { db in
                let query = ExperienceRecord
                    .including(required: ExperienceRecord.spot)
                return try ExperienceInfoSummary.fetchAll(db, query)
            }
        } transformError: { error in
            ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchExperience(withID id: UUID) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed {
        try await perform {
            try await db.read { db in
                let request = ExperienceRecord
                    .including(required: ExperienceRecord.spot)
                    .including(all: ExperienceRecord.ratings)
                    .filter(id: id)
                guard let experienceInfo = try ExperienceInfoDetailed.fetchOne(db, request) else {
                    throw ExperiencesRepositoryError.experienceNotFound
                }
                return experienceInfo
            }
        } transformError: { error in
            ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func observeExperience(withID id: UUID) async -> any AsyncSequence<ExperienceInfoDetailed, ExperiencesRepositoryError> {
        let request = ExperienceRecord
            .including(required: ExperienceRecord.spot)
            .including(all: ExperienceRecord.ratings)
            .filter(id: id)
        let observation = ValueObservation.tracking { db in
            guard let experience = try ExperienceInfoDetailed.fetchOne(db, request) else {
                throw ExperiencesRepositoryError.experienceNotFound
            }
            return experience
        }
        let baseStream = observation.values(in: db)

        return ErrorTransformingSequence<ExperienceInfoDetailed, ExperiencesRepositoryError>(
            baseStream: baseStream,
            transformError: { error in
                if let experiencesError = error as? ExperiencesRepositoryError {
                    experiencesError
                } else {
                    ExperiencesRepositoryError.databaseError(error.localizedDescription)
                }
            }
        )
    }

    public func observeExperiences(request: FetchExperiencesDataRequest = .default) async -> any AsyncSequence<[ExperienceInfoSummary], ExperiencesRepositoryError> {
        let query = ExperienceRecord
            .including(required: ExperienceRecord.spot)
        let observation = ValueObservation.tracking { db in
            try ExperienceInfoSummary.fetchAll(db, query)
        }
        let baseStream = observation.values(in: db)

        return ErrorTransformingSequence<[ExperienceInfoSummary], ExperiencesRepositoryError>(
            baseStream: baseStream,
            transformError: { error in
                if let experiencesError = error as? ExperiencesRepositoryError {
                    experiencesError
                } else {
                    ExperiencesRepositoryError.databaseError(error.localizedDescription)
                }
            }
        )
    }
}
