import EatadakiData
import EatadakiLocationKit
import SwiftUI

public typealias SpotsDetailViewModelDependencies = SpotsRepositoryProviding

public enum SpotsDetailViewModelError: Error, Equatable {
    case unableToLoad
}

@Observable
@MainActor
public final class SpotDetailViewModel {
    /// The `Spot` data represented within this view model when loaded
    public struct Spot: Identifiable, Equatable, Sendable {
        
        public let backingData: SpotRecord
        
        public var id: UUID { backingData.id }
        public var name: String { backingData.name }
        public var coordinates: Coordinates { Coordinates(latitude: backingData.latitude, longitude: backingData.longitude) }

        public init(from spotInfo: SpotRecord) {
            self.backingData = spotInfo
        }
    }
    
    /// The `Spot` data represented within this view when we have some information, but not all.
    public struct Preview {
        public var name: String
        public var coordinates: Coordinates
    }

    public enum Stage: Equatable, Sendable {
        case uninitialized // App hasn't called `initialized()`
        case initializing // Reading detail data
        case loaded(Spot) // Fetching finished successfully
        case loadingFailed(SpotsDetailViewModelError) // Fetching finished unsuccessfully
    }

    private let dependencies: SpotsDetailViewModelDependencies
    private let spotIds: SpotIDs

    public var stage: Stage = .uninitialized

    public var preview: Preview?
    public var spot: Spot? {
        switch stage {
        case .loaded(let spot):
            spot
        default:
            nil
        }
    }

    public var navigationTitle: String {
        spot?.name ?? preview?.name ?? ""
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotInfoListing: SpotInfoSummary,
    ) {
        self.dependencies = dependencies
        self.spotIds = SpotIDs(id: spotInfoListing.spot.id)
        self.preview = Preview(
            name: spotInfoListing.spot.name,
            coordinates: spotInfoListing.coordinates,
        )
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotIds: SpotIDs,
    ) {
        self.dependencies = dependencies
        self.spotIds = spotIds
    }

    public func initialize() async {
        guard case .uninitialized = stage else { return }
        stage = .initializing
        do {
            // TODO: We should route through a dep that can hit the network(s) if no cached record.
            let spot = try await dependencies.spotsRepository.fetchSpot(withIDs: spotIds)
            let spotInfoDetail = Spot(from: spot)
            stage = .loaded(spotInfoDetail)
        } catch {
            stage = .loadingFailed(.unableToLoad)
        }
    }
}

#if DEBUG
public struct FakeSpotDetailViewModelDependencies: SpotsRepositoryProviding {
    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: SpotsRepository { fakeSpotsRepository }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
