import EatadakiData
import EatadakiExperiencesKit
import Foundation
import MapKit
import Observation
import Testing

@MainActor
@Suite("SpotDetailViewModel Tests")
struct SpotDetailViewModelTests {
    @Test("initial state with spotInfoListing has uninitialized stage and preview")
    func testInitialStateWithSpotInfoListing() async throws {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let spot = SpotRecord.peacePagoda
        let spotInfoListing = SpotInfoSummary(spot: spot)
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.spot == nil)
        #expect(viewModel.navigationTitle == "Peace Pagoda")
        let preview = try #require(viewModel.preview)
        #expect(preview.name == "Peace Pagoda")
        #expect(preview.coordinates.latitude == 37.7849447)
        #expect(preview.coordinates.longitude == -122.4303306)
    }

    @Test("initial state with spotIds has uninitialized stage and no preview")
    func testInitialStateWithSpotIds() async {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.preview == nil)
        #expect(viewModel.spot == nil)
        #expect(viewModel.navigationTitle == "")
    }

    @Test("navigationTitle uses spotDetail name when loaded")
    func testNavigationTitleUsesSpotDetailName() async {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Loaded Spot Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithID = { _ in
            SpotInfoDetailed(spot: spot, experiences: [])
        }
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        await viewModel.initialize()

        #expect(viewModel.navigationTitle == "Loaded Spot Name")
    }

    @Test("navigationTitle uses preview name when not loaded")
    func testNavigationTitleUsesPreviewName() async {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Preview Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spotInfoListing = SpotInfoSummary(spot: spot)
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )

        #expect(viewModel.navigationTitle == "Preview Name")
    }

    @Test("initialize sets stage to initializing then loaded on success")
    func testInitializeSuccess() async throws {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithID = { _ in
            SpotInfoDetailed(spot: spot, experiences: [])
        }
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        await viewModel.initialize()

        #expect(viewModel.stage == .loaded(SpotDetailViewModel.Spot(from: SpotInfoDetailed(spot: spot, experiences: []))))
        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithID == [SpotRecord.peacePagoda.id])

        let spotDetail = try #require(viewModel.spot)
        #expect(spotDetail.name == "Test Spot")
        #expect(spotDetail.id == spot.id)
    }

    @Test("initialize sets stage to loadingFailed on error")
    func testInitializeFailure() async {
        let dependencies = FakeSpotDetailViewModelDependencies()
        dependencies.fakeSpotsRepository.stubFetchSpotWithID = { (_) async throws(SpotsRepositoryError) -> SpotInfoDetailed in
            throw SpotsRepositoryError.spotNotFound
        }
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        await viewModel.initialize()

        #expect(viewModel.stage == .loadingFailed(.unableToLoad))
        #expect(viewModel.spot == nil)
        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithID.count == 1)
    }

    @Test("initialize does not run twice")
    func testInitializeDoesNotRunTwice() async {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithID = { _ in
            SpotInfoDetailed(spot: spot, experiences: [])
        }
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        await viewModel.initialize()
        await viewModel.initialize()

        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithID.count == 1)
    }

    @Test("spotDetail returns nil when not loaded")
    func testSpotDetailReturnsNilWhenNotLoaded() async {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        #expect(viewModel.spot == nil)
    }

    @Test("spotDetail returns detail when loaded")
    func testSpotDetailReturnsDetailWhenLoaded() async throws {
        let dependencies = FakeSpotDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithID = { _ in
            SpotInfoDetailed(spot: spot, experiences: [])
        }
        let viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )

        await viewModel.initialize()

        let loadedDetail = try #require(viewModel.spot)
        #expect(loadedDetail.id == spot.id)
        #expect(loadedDetail.name == spot.name)
        #expect(loadedDetail.coordinates.latitude == spot.latitude)
        #expect(loadedDetail.coordinates.longitude == spot.longitude)
    }
}
