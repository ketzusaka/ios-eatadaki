import EatadakiData
import MapKit

public enum SpotsSearcherError: Error, Equatable {
    case failedToSaveSpot(SpotsRepositoryError)
    case invalidRequest(String)
    case providerError(String)
}

public protocol SpotsSearcher {
    func findAndCacheSpots(request: FindSpotsRequest) async throws(SpotsSearcherError)
}

public protocol SpotsSearcherProviding {
    var spotsSearcher: SpotsSearcher { get }
}

public actor RealSpotSearcher: SpotsSearcher {
    private let spotsRepository: any SpotsRepository
    private let spotsProvider: any SpotsProvider

    public init(
        spotsRepository: any SpotsRepository,
        spotsProvider: any SpotsProvider,
    ) {
        self.spotsRepository = spotsRepository
        self.spotsProvider = spotsProvider
    }

    public func findAndCacheSpots(request: FindSpotsRequest) async throws(SpotsSearcherError) {
        let result = try await spotsProvider.findSpots(request: request)
        for foundSpot in result.spots {
            let spot = SpotRecord(from: foundSpot)
            do {
                try await spotsRepository.save(spot: spot)
            } catch {
                throw SpotsSearcherError.failedToSaveSpot(error)
            }
        }
        // TODO: Support multiple providers
    }
}
