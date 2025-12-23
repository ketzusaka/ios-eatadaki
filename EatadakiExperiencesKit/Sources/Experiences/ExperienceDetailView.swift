import EatadakiData
import EatadakiUI
import SwiftUI

public typealias ExperienceDetailViewDependencies = ExperienceDetailViewModelDependencies

public struct ExperienceDetailView: View {
    public protocol SpotCardViewData {
        var spotId: UUID { get }
        var spotName: String { get }
    }

    public protocol ExperienceCardViewData {
        var experienceName: String { get }
        var experienceDescription: String? { get }
        var rating: Int? { get }
        var ratingNote: String? { get }
    }

    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: ExperienceDetailViewModel
    let dependencies: ExperienceDetailViewDependencies

    public init(
        dependencies: ExperienceDetailViewDependencies,
        experienceSummary: ExperienceInfoSummary,
    ) {
        self.dependencies = dependencies
        self.viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceSummary: experienceSummary,
        )
    }

    public init(
        dependencies: ExperienceDetailViewModelDependencies,
        experienceId: UUID,
    ) {
        self.dependencies = dependencies
        self.viewModel = ExperienceDetailViewModel(
            dependencies: dependencies,
            experienceId: experienceId,
        )
    }

    public var body: some View {
        ScrollView([.vertical]) {
            switch viewModel.stage {
            case .uninitialized, .initializing:
                if let preview = viewModel.preview {
                    VStack(alignment: .leading, spacing: 16) {
                        experienceSectionView(for: preview)

                        spotSectionView(for: preview)

                        ratingSectionView(for: preview)

                        LoadingView()
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    LoadingView()
                }
            case .loaded(let experience):
                VStack(alignment: .leading, spacing: 16) {
                    experienceSectionView(for: experience)

                    spotSectionView(for: experience)

                    ratingSectionView(for: experience)

                    // TODO: Past ratings list

                    Spacer(minLength: 16)
                }
            case .loadingFailed:
                Text("Unable to load experience")
                    .padding()
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .onFirstAppear {
            await viewModel.initialize()
        }
    }

    @ViewBuilder
    private func spotSectionView(for spot: SpotCardViewData) -> some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack(alignment: .leading) {
            Text("Spot")
                .headlineTextStyling(using: theme)

            spotCardView(for: spot)
        }
    }

    @ViewBuilder
    private func spotCardView(for spot: SpotCardViewData) -> some View {
        NavigationLink(value: ExperiencesScreen.spotDetails(.id(spot.spotId))) {
            HStack {
                Text(spot.spotName)

                Spacer()

                // TODO: Add distance from current location here
            }
        }
    }

    @ViewBuilder
    private func experienceSectionView(for experience: ExperienceCardViewData) -> some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack(alignment: .leading) {
            Text("Experience")
                .headlineTextStyling(using: theme)

            experienceCardView(for: experience)
        }
    }

    @ViewBuilder
    private func experienceCardView(for experience: ExperienceCardViewData) -> some View {
        HStack {
            Text("Name")

            Spacer()

            Text(experience.experienceName)
        }

        // TODO: Category / etc

        if let experienceDescription = experience.experienceDescription, !experienceDescription.isEmpty {
            HStack {
                Text("Description")

                Spacer()

                Text(experienceDescription)
            }
        }
    }

    @ViewBuilder
    private func ratingSectionView(for experience: ExperienceCardViewData) -> some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack(alignment: .leading) {
            Text("Rating")
                .headlineTextStyling(using: theme)

            ratingCardView(for: experience)
        }
    }

    @ViewBuilder
    private func ratingCardView(for experience: ExperienceCardViewData) -> some View {
        let theme = themeManager.tokens(for: colorScheme)

        if let rating = experience.rating {
            VStack(spacing: 8) {
                RatingStarsView(rating: rating, starSize: 32)
                    .frame(maxWidth: .infinity)

                if let note = experience.ratingNote {
                    Text(note)
                        .captionTextStyling(using: theme)
                }

                Button("Update rating") {
                    // TODO: Present Edit Rating experience
                }
            }
        } else {
            VStack {
                Text("You have not rated this experience yet.")
                Button("Add a rating!") {
                    // TODO: Present Edit Rating Experience.
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
#Preview("Success from experience ID") {
    let dependencies = FakeExperienceDetailViewModelDependencies {
        $0.fakeExperiencesRepository.stubFetchExperienceWithID = { id in
            ExperienceInfoDetailed(
                spot: SpotRecord.peacePagoda,
                experience: ExperienceRecord(
                    id: id,
                    spotId: SpotRecord.peacePagoda.id,
                    name: "Ramen",
                    description: "Great ramen experience",
                    rating: 9,
                    ratingNote: "This ramen is the best I've ever had! It's miso pork broth was deep and rich, and the noodles were perfectly cooked. The broth was so flavorful that it made my taste buds do a happy dance.",
                    createdAt: .now,
                ),
                ratingHistory: [],
            )
        }
    }

    NavigationStack {
        ExperienceDetailView(
            dependencies: dependencies,
            experienceId: UUID(),
        )
        .environment(ThemeManager())
    }
}

#Preview("Success without Rating") {
    let dependencies = FakeExperienceDetailViewModelDependencies {
        $0.fakeExperiencesRepository.stubFetchExperienceWithID = { id in
            ExperienceInfoDetailed(
                spot: SpotRecord.peacePagoda,
                experience: ExperienceRecord(
                    id: id,
                    spotId: SpotRecord.peacePagoda.id,
                    name: "Ramen",
                    description: "Great ramen experience",
                    createdAt: .now,
                ),
                ratingHistory: [],
            )
        }
    }

    NavigationStack {
        ExperienceDetailView(
            dependencies: dependencies,
            experienceId: UUID(),
        )
        .environment(ThemeManager())
    }
}

#Preview("Preview data") {
    let dependencies = FakeExperienceDetailViewModelDependencies {
        $0.fakeExperiencesRepository.stubFetchExperienceWithID = { (_) async throws(ExperiencesRepositoryError) -> ExperienceInfoDetailed in
            try? await Task.sleep(nanoseconds: .max)
            throw ExperiencesRepositoryError.experienceNotFound
        }
    }

    NavigationStack {
        ExperienceDetailView(
            dependencies: dependencies,
            experienceSummary: ExperienceInfoSummary(
                spot: SpotRecord.peacePagoda,
                experience: ExperienceRecord(
                    id: UUID(),
                    spotId: SpotRecord.peacePagoda.id,
                    name: "Ramen",
                    rating: 9,
                    ratingNote: "This ramen is the best I've ever had! It's miso pork broth was deep and rich, and the noodles were perfectly cooked. The broth was so flavorful that it made my taste buds do a happy dance.",
                    createdAt: .now,
                )
            ),
        )
        .environment(ThemeManager())
    }
}
#endif
