import EatadakiData
import EatadakiExperiencesKit
import Foundation
import Observation
import Testing

@MainActor
@Suite("ExperienceDetailViewModel Tests")
struct ExperienceDetailViewModelTests {
    @Test("initial state with experienceSummary has uninitialized stage and preview")
    func testInitialStateWithExperienceSummary() async throws {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experience = ExperienceRecord(
            id: UUID(),
            spotId: SpotRecord.peacePagoda.id,
            name: "Ramen Experience",
            createdAt: .now,
        )
        let experienceSummary = ExperienceInfoSummary(
            spot: SpotRecord.peacePagoda,
            experience: experience,
        )
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceSummary: experienceSummary,
        )

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.experience == nil)
        #expect(viewModel.navigationTitle == "Ramen Experience")
        let preview = try #require(viewModel.preview)
        #expect(preview.experienceName == "Ramen Experience")
        #expect(preview.spotName == "Peace Pagoda")
    }

    @Test("initial state with experienceId has uninitialized stage and no preview")
    func testInitialStateWithExperienceId() async {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experienceId = UUID()
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )

        #expect(viewModel.stage == .uninitialized)
        #expect(viewModel.preview == nil)
        #expect(viewModel.experience == nil)
        #expect(viewModel.navigationTitle == "")
    }

    @Test("navigationTitle uses experience name when loaded")
    func testNavigationTitleUsesExperienceName() async {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experienceId = UUID()
        let experience = ExperienceRecord(
            id: experienceId,
            spotId: SpotRecord.peacePagoda.id,
            name: "Loaded Experience Name",
            createdAt: .now,
        )
        dependencies.fakeExperiencesRepository.stubFetchExperienceWithID = { _ in
            ExperienceInfoDetailed(
                spot: SpotRecord.peacePagoda,
                experience: experience,
                ratingHistory: [],
            )
        }
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )

        await viewModel.initialize()

        #expect(viewModel.navigationTitle == "Loaded Experience Name")
    }

    @Test("navigationTitle uses preview name when not loaded")
    func testNavigationTitleUsesPreviewName() async {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experience = ExperienceRecord(
            id: UUID(),
            spotId: SpotRecord.peacePagoda.id,
            name: "Preview Name",
            createdAt: .now,
        )
        let experienceSummary = ExperienceInfoSummary(
            spot: SpotRecord.peacePagoda,
            experience: experience,
        )
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceSummary: experienceSummary,
        )

        #expect(viewModel.navigationTitle == "Preview Name")
    }

    @Test("initialize sets stage to initializing then loaded on success")
    func testInitializeSuccess() async throws {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experienceId = UUID()
        let experience = ExperienceRecord(
            id: experienceId,
            spotId: SpotRecord.peacePagoda.id,
            name: "Test Experience",
            description: "Test description",
            rating: 8,
            createdAt: .now,
        )
        let experienceInfoDetailed = ExperienceInfoDetailed(
            spot: SpotRecord.peacePagoda,
            experience: experience,
            ratingHistory: [],
        )
        dependencies.fakeExperiencesRepository.stubFetchExperienceWithID = { _ in
            experienceInfoDetailed
        }
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )

        await viewModel.initialize()

        #expect(viewModel.stage == .loaded(ExperienceDetailViewModel.Experience(from: experienceInfoDetailed)))
        #expect(dependencies.fakeExperiencesRepository.invocationsFetchExperienceWithID == [experienceId])

        let loadedExperience = try #require(viewModel.experience)
        #expect(loadedExperience.name == "Test Experience")
        #expect(loadedExperience.id == experienceId)
        #expect(loadedExperience.description == "Test description")
        #expect(loadedExperience.rating == 8)
    }

    @Test("initialize sets stage to loadingFailed on error")
    func testInitializeFailure() async {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experienceId = UUID()
        dependencies.fakeExperiencesRepository.stubFetchExperienceWithID = { (_) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed in
            throw ExperiencesRepositoryError.experienceNotFound
        }
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )

        await viewModel.initialize()

        #expect(viewModel.stage == .loadingFailed(.unableToLoad))
        #expect(viewModel.experience == nil)
        #expect(dependencies.fakeExperiencesRepository.invocationsFetchExperienceWithID.count == 1)
    }

    @Test("initialize does not run twice")
    func testInitializeDoesNotRunTwice() async {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experienceId = UUID()
        let experience = ExperienceRecord(
            id: experienceId,
            spotId: SpotRecord.peacePagoda.id,
            name: "Test Experience",
            createdAt: .now,
        )
        dependencies.fakeExperiencesRepository.stubFetchExperienceWithID = { _ in
            ExperienceInfoDetailed(
                spot: SpotRecord.peacePagoda,
                experience: experience,
                ratingHistory: [],
            )
        }
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )

        await viewModel.initialize()
        await viewModel.initialize()

        #expect(dependencies.fakeExperiencesRepository.invocationsFetchExperienceWithID.count == 1)
    }

    @Test("experience returns nil when not loaded")
    func testExperienceReturnsNilWhenNotLoaded() async {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: UUID(),
        )

        #expect(viewModel.experience == nil)
    }

    @Test("experience returns detail when loaded")
    func testExperienceReturnsDetailWhenLoaded() async throws {
        let dependencies = FakeExperienceDetailViewModelDependencies()
        let experienceId = UUID()
        let experience = ExperienceRecord(
            id: experienceId,
            spotId: SpotRecord.peacePagoda.id,
            name: "Test Experience",
            description: "Test description",
            rating: 9,
            createdAt: .now,
        )
        dependencies.fakeExperiencesRepository.stubFetchExperienceWithID = { _ in
            ExperienceInfoDetailed(
                spot: SpotRecord.peacePagoda,
                experience: experience,
                ratingHistory: [],
            )
        }
        let viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )

        await viewModel.initialize()

        let loadedDetail = try #require(viewModel.experience)
        #expect(loadedDetail.id == experienceId)
        #expect(loadedDetail.name == "Test Experience")
        #expect(loadedDetail.description == "Test description")
        #expect(loadedDetail.rating == 9)
        #expect(loadedDetail.spot.id == SpotRecord.peacePagoda.id)
    }
}

