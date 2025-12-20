import CoreLocation
import EatadakiData
import EatadakiKit
import EatadakiLocationKit
import Foundation
import Observation

public typealias SpotsViewModelDependencies = LocationServiceProviding & DeviceConfigurationControllerProviding & ExperiencesRepositoryProviding & SpotsRepositoryProviding & SpotsSearcherProviding

@Observable
@MainActor
public final class SpotsViewModel {
    public struct Spot: Identifiable {
        public let backingData: SpotInfoSummary

        public var id: UUID { backingData.spot.id }
        public var name: String { backingData.spot.name }
        public var coordinates: Coordinates { Coordinates(latitude: backingData.spot.latitude, longitude: backingData.spot.latitude) }

        public init(from spotSummary: SpotInfoSummary) {
            self.backingData = spotSummary
        }
    }

    public enum Stage {
        case uninitialized // App hasn't called `initialized()`
        case initializing // Determines opt-in state
        case requiresOptIn // Skipped once the user opts in
        case locating // Locating the user
        case located // User has been located
        case fetching // Fetching content
        case fetched // Fetching finished
    }

    public var stage: Stage = .uninitialized
    public var currentLocation: CLLocation?
    public var spots: [Spot] = []
    public var hasReceivedContent = false
    public var searchQuery: String = "" {
        didSet {
            observeSpots()
        }
    }

    private let dependencies: SpotsViewModelDependencies
    private var observationTask: Task<Void, any Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    public init(
        dependencies: SpotsViewModelDependencies,
    ) {
        self.dependencies = dependencies
    }

    public func initialize() async {
        // Check opt-in status
        let isOptedIn: Bool
        do {
            isOptedIn = try await dependencies.deviceConfigurationController.optInLocationServices
        } catch {
            isOptedIn = false
        }

        observeSpots()

        if isOptedIn {
            stage = .locating
            await refreshCurrentLocation()
            await refreshSpots()
        } else {
            stage = .requiresOptIn
        }
    }

    public func optIntoLocationServices() async {
        do {
            try await dependencies.deviceConfigurationController.setOptInLocationServices(true)
            await refreshCurrentLocation()
            await refreshSpots()
        } catch {
            // TODO: Handle failure
        }
    }

    public func refreshCurrentLocation() async {
        do {
            stage = .locating
            currentLocation = try await dependencies.locationService.obtain()
            stage = .located
            observeSpots()
        } catch {
            // TODO: Handle failed location fetch
        }
    }

    public func refreshSpots() async {
        stage = .fetching
        var request = FindSpotsRequest()
        request.location = currentLocation
        request.query = searchQuery.isEmpty ? nil : searchQuery
        try? await dependencies.spotsSearcher.findAndCacheSpots(request: request)
        hasReceivedContent = true
        stage = .fetched
    }

    // Refreshes our data observer. Should be called on init, location change, or filtering change
    private func observeSpots() {
        let request = spotsDataRequest
        observationTask = Task { [weak self] in
            guard let observation = await self?.dependencies.spotsRepository.observeSpots(request: request) else {
                return
            }
            for try await spotSummaries in observation {
                guard !Task.isCancelled else { return }
                guard let self else { return }
                let listableSpots = spotSummaries.map(Spot.init(from:))
                await self.updateSpots(with: listableSpots)
            }
        }
    }

    private func updateSpots(with spots: [Spot]) async {
        self.spots = spots
    }

    private var spotsDataRequest: FetchSpotsDataRequest {
        let query = searchQuery.isEmpty ? nil : searchQuery
        if let currentLocation {
            return FetchSpotsDataRequest(
                sort: FetchSpotsDataRequest.Sort(
                    field: .distance(from: currentLocation.coordinate),
                    direction: .ascending,
                ),
                query: query,
            )
        } else {
            return FetchSpotsDataRequest(
                sort: FetchSpotsDataRequest.Sort(
                    field: .name,
                    direction: .ascending,
                ),
                query: query,
            )
        }
    }
}

#if DEBUG
public struct FakeSpotsViewModelDependencies: DeviceConfigurationControllerProviding, ExperiencesRepositoryProviding, LocationServiceProviding, SpotsRepositoryProviding, SpotsSearcherProviding {
    public var fakeExperiencesRepository = FakeExperiencesRepository()
    public var experiencesRepository: any ExperiencesRepository { fakeExperiencesRepository }

    public var fakeLocationService = FakeLocationService()
    public var locationService: LocationService { fakeLocationService }

    public var fakeDeviceConfigurationController = FakeDeviceConfigurationController()
    public var deviceConfigurationController: DeviceConfigurationController { fakeDeviceConfigurationController }

    public var fakeSpotsRepository = FakeSpotsRepository()
    public var spotsRepository: SpotsRepository { fakeSpotsRepository }

    public var fakeSpotsSearcher = FakeSpotsSearcher()
    public var spotsSearcher: SpotsSearcher { fakeSpotsSearcher }

    public init(_ configure: ((Self) -> Void)? = nil) {
        configure?(self)
    }
}
#endif
