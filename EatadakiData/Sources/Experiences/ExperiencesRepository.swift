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
    
    func fetchExperiences(request: FetchExperiencesDataRequest) async throws(ExperiencesRepositoryError) -> [ExperienceInfoSummary]
    
    func fetchExperience(withID id: UUID) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed
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
        // Validate that rating's spotId matches the provided spotId
        guard rating == nil || rating!.spotId == spotId else {
            throw ExperiencesRepositoryError.invalidRating
        }

        do {
            return try await db.write { db in
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
        } catch let error as ExperiencesRepositoryError {
            throw error
        } catch {
            throw ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchExperiences(request: FetchExperiencesDataRequest = .default) async throws(ExperiencesRepositoryError) -> [ExperienceInfoSummary] {
        do {
            return try await db.read { db in
                let query = ExperienceRecord
                    .including(required: ExperienceRecord.spot)
                return try ExperienceInfoSummary.fetchAll(db, query)
            }
        } catch let error as ExperiencesRepositoryError {
            throw error
        } catch {
            throw ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }

    public func fetchExperience(withID id: UUID) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed {
        do {
            return try await db.read { db in
                let request = ExperienceRecord
                    .including(required: ExperienceRecord.spot)
                    .including(all: ExperienceRecord.ratings)
                    .filter(id: id)
                guard let experienceInfo = try ExperienceInfoDetailed.fetchOne(db, request) else {
                    throw ExperiencesRepositoryError.experienceNotFound
                }
                return experienceInfo
            }
        } catch let error as ExperiencesRepositoryError {
            throw error
        } catch {
            throw ExperiencesRepositoryError.databaseError(error.localizedDescription)
        }
    }
}
