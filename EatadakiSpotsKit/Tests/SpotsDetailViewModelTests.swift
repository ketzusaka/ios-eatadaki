import EatadakiData
import EatadakiSpotsKit
import Foundation
import MapKit
import Observation
import Testing

@MainActor
@Suite("SpotsDetailViewModel Tests")
struct SpotsDetailViewModelTests {
    @Test("initial state with spotInfoListing has uninitialized stage and preview")
    func testInitialStateWithSpotInfoListing() async throws {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spot = SpotRecord.peacePagoda
        let spotInfoListing = SpotInfoSummary(from: spot)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.spotDetail == nil)
        #expect(viewModel.navigationTitle == "Peace Pagoda")
        let preview = try #require(viewModel.preview)
        #expect(preview.name == "Peace Pagoda")
        #expect(preview.coordinates.latitude == 37.7849447)
        #expect(preview.coordinates.longitude == -122.4303306)
    }

    @Test("initial state with spotIds has uninitialized stage and no preview")
    func testInitialStateWithSpotIds() async {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.preview == nil)
        #expect(viewModel.spotDetail == nil)
        #expect(viewModel.navigationTitle == "")
    }

    @Test("navigationTitle uses spotDetail name when loaded")
    func testNavigationTitleUsesSpotDetailName() async {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Loaded Spot Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in spot }
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        await viewModel.initialize()

        #expect(viewModel.navigationTitle == "Loaded Spot Name")
    }

    @Test("navigationTitle uses preview name when not loaded")
    func testNavigationTitleUsesPreviewName() async {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Preview Name",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        let spotInfoListing = SpotInfoSummary(from: spot)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )

        #expect(viewModel.navigationTitle == "Preview Name")
    }

    @Test("initialize sets stage to initializing then loaded on success")
    func testInitializeSuccess() async throws {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in spot }
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        await viewModel.initialize()

        #expect(viewModel.stage == .loaded(SpotInfoDetailed(from: spot)))
        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithIDs.count == 1)
        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithIDs.first == spotIds)

        let spotDetail = try #require(viewModel.spotDetail)
        #expect(spotDetail.name == "Test Spot")
        #expect(spotDetail.id == spot.id)
    }

    @Test("initialize sets stage to loadingFailed on error")
    func testInitializeFailure() async {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        dependencies.fakeSpotsRepository.stubFetchSpotWithIDs = { (_) async throws(SpotsRepositoryError) -> SpotRecord in
            throw SpotsRepositoryError.spotNotFound
        }
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        await viewModel.initialize()

        #expect(viewModel.stage == .loadingFailed(.unableToLoad))
        #expect(viewModel.spotDetail == nil)
        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithIDs.count == 1)
    }

    @Test("initialize does not run twice")
    func testInitializeDoesNotRunTwice() async {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in spot }
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        await viewModel.initialize()
        await viewModel.initialize()

        #expect(dependencies.fakeSpotsRepository.invocationsFetchSpotWithIDs.count == 1)
    }

    @Test("spotDetail returns nil when not loaded")
    func testSpotDetailReturnsNilWhenNotLoaded() async {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        #expect(viewModel.spotDetail == nil)
    }

    @Test("spotDetail returns detail when loaded")
    func testSpotDetailReturnsDetailWhenLoaded() async throws {
        let dependencies = FakeSpotsDetailViewModelDependencies()
        let spot = SpotRecord(
            id: UUID(),
            mapkitId: "I6FD7682FD36BB3BE",
            name: "Test Spot",
            latitude: 37.7849447,
            longitude: -122.4303306,
            createdAt: .now,
        )
        dependencies.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in spot }
        let spotIds = SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId)
        let viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )

        await viewModel.initialize()

        let loadedDetail = try #require(viewModel.spotDetail)
        #expect(loadedDetail.id == spot.id)
        #expect(loadedDetail.name == spot.name)
        #expect(loadedDetail.coordinates.latitude == spot.latitude)
        #expect(loadedDetail.coordinates.longitude == spot.longitude)
    }
}
