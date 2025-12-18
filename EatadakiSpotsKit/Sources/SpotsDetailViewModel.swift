import EatadakiData
import EatadakiLocationKit
import SwiftUI

public typealias SpotsDetailViewModelDependencies = SpotsRepositoryProviding

public enum SpotsDetailViewModelError: Error, Equatable {
    case unableToLoad
}

@Observable
@MainActor
public final class SpotsDetailViewModel {
    
    public struct Preview {
        public var name: String
        public var coordinates: Coordinates
    }
    
    public enum Stage: Equatable, Sendable {
        case uninitialized // App hasn't called `initialized()`
        case initializing // Reading detail data
        case loaded(SpotInfoDetail) // Fetching finished successfully
        case loadingFailed(SpotsDetailViewModelError) // Fetching finished unsuccessfully
    }
    
    private let dependencies: SpotsDetailViewModelDependencies
    private let spotIds: SpotIDs
    
    public var stage: Stage = .uninitialized
    
    public var preview: Preview?
    public var spotDetail: SpotInfoDetail? {
        switch stage {
        case .loaded(let spotDetail):
            spotDetail
        default:
            nil
        }
    }
    
    public var navigationTitle: String {
        spotDetail?.name ?? preview?.name ?? ""
    }
    
    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotInfoListing: SpotInfoListing,
    ) {
        self.dependencies = dependencies
        self.spotIds = SpotIDs(id: spotInfoListing.id)
        self.preview = Preview(
            name: spotInfoListing.name,
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
            let spotInfoDetail = SpotInfoDetail(from: spot)
            stage = .loaded(spotInfoDetail)
        } catch {
            stage = .loadingFailed(.unableToLoad)
        }
    }
}

#if DEBUG
public struct FakeSpotsDetailViewModelDependencies: SpotsRepositoryProviding {
    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: SpotsRepository { fakeSpotsRepository }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
