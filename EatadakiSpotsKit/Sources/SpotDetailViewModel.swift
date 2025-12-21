import EatadakiData
import EatadakiLocationKit
import SwiftUI

public typealias SpotsDetailViewModelDependencies = SpotsRepositoryProviding & ExperiencesRepositoryProviding

public enum SpotsDetailViewModelError: Error, Equatable {
    case unableToLoad
}

@Observable
@MainActor
public final class SpotDetailViewModel {
    /// The `Spot` data represented within this view model when loaded
    public struct Spot: Identifiable, Equatable, Sendable {
        public let backingData: SpotInfoDetailed

        public var id: UUID { backingData.spot.id }
        public var name: String { backingData.spot.name }
        public var coordinates: Coordinates { Coordinates(latitude: backingData.spot.latitude, longitude: backingData.spot.longitude) }
        public var experiences: [ExperienceRecord] { backingData.experiences }

        public init(from spotInfo: SpotInfoDetailed) {
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

    let dependencies: SpotsDetailViewModelDependencies

    public let spotId: UUID
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

    public var isShowingAddExperienceFlow: Bool = false

    private var observationTask: Task<Void, any Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotInfoListing: SpotInfoSummary,
    ) {
        self.dependencies = dependencies
        self.spotId = spotInfoListing.spot.id
        self.preview = Preview(
            name: spotInfoListing.spot.name,
            coordinates: spotInfoListing.coordinates,
        )
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotId: UUID,
    ) {
        self.dependencies = dependencies
        self.spotId = spotId
    }

    public func initialize() async {
        guard case .uninitialized = stage else { return }
        stage = .initializing
        do {
            // TODO: We should route through a dep that can hit the network(s) if no cached record.
            let spotInfoDetailed = try await dependencies.spotsRepository.fetchSpot(withID: spotId)
            let spot = Spot(from: spotInfoDetailed)
            stage = .loaded(spot)
            observeSpotUpdates()
        } catch {
            stage = .loadingFailed(.unableToLoad)
        }
    }

    private func observeSpotUpdates() {
        observationTask = Task { [spotId, weak self] in
            guard let observation = await self?.dependencies.spotsRepository.observeSpot(withID: spotId) else {
                return
            }

            do {
                for try await spotInfoDetailed in observation {
                    guard !Task.isCancelled else { return }
                    guard let self else { return }
                    let spot = Spot(from: spotInfoDetailed)
                    await self.updateSpot(spot)
                }
            } catch {
                // TODO: Handle error
            }
        }
    }

    private func updateSpot(_ spot: Spot) async {
        stage = .loaded(spot)
    }

    private func updateSpotNotFound() async {
        stage = .loadingFailed(.unableToLoad)
    }
}

#if DEBUG
public struct FakeSpotDetailViewModelDependencies: SpotsRepositoryProviding, ExperiencesRepositoryProviding {
    public var fakeExperiencesRepository = FakeExperiencesRepository()
    public var experiencesRepository: any ExperiencesRepository { fakeExperiencesRepository }

    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: SpotsRepository { fakeSpotsRepository }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
