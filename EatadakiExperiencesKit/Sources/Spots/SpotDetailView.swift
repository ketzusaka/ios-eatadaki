import EatadakiData
import EatadakiLocationKit
import EatadakiUI
import MapKit
import SwiftUI

public typealias SpotsDetailViewDependencies = SpotsDetailViewModelDependencies

public struct SpotDetailView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: SpotDetailViewModel
    let dependencies: SpotsDetailViewDependencies

    public init(
        dependencies: SpotsDetailViewDependencies,
        spotInfoListing: SpotInfoSummary,
    ) {
        self.dependencies = dependencies
        self.viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotId: UUID,
    ) {
        self.dependencies = dependencies
        self.viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotId: spotId,
        )
    }

    public var body: some View {
        ScrollView([.vertical]) {
            switch viewModel.stage {
            case .uninitialized, .initializing:
                if let preview = viewModel.preview {
                    mapView(name: preview.name, coordinates: preview.coordinates)

                    LoadingView()
                } else {
                    LoadingView()
                }
            case .loaded(let spot):
                mapView(name: spot.name, coordinates: spot.coordinates)

                Text("Experiences")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                if spot.experiences.isEmpty {
                    noExperiencesView
                } else {
                    VStack(spacing: 8) {
                        ForEach(spot.experiences) { experience in
                            NavigationLink {
                                ExperienceDetailView(
                                    dependencies: dependencies,
                                    experienceSummary: ExperienceInfoSummary(spot: spot.backingData.spot, experience: experience),
                                )
                            } label: {
                                experienceRow(for: experience)
                            }
                            .padding([.leading, .trailing])
                        }
                    }

                    Button("Add a new experience") {
                        viewModel.isShowingAddExperienceFlow = true
                    }

                    Spacer(minLength: 16)
                }

            case .loadingFailed:
                Text("Uh oh!")
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .onFirstAppear {
            await viewModel.initialize()
        }
        .sheet(isPresented: $viewModel.isShowingAddExperienceFlow) {
            AddExperienceView(
                dependencies: dependencies,
                spotId: viewModel.spotId,
                isPresented: $viewModel.isShowingAddExperienceFlow,
            )
        }
    }

    @ViewBuilder
    private func mapView(name: String, coordinates: Coordinates) -> some View {
        let position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025),
            )
        )

        Map(position: .constant(position)) {
            Marker(name, coordinate: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
        }
        .disabled(true)
        .frame(height: 200)
        .padding()
    }

    @ViewBuilder
    private var noExperiencesView: some View {
        VStack(spacing: 8) {
            Text("Add the first!")
            Text("No one has added an experience to this spot yet. Be the first!")
            Button("Add experience") {
                viewModel.isShowingAddExperienceFlow = true
            }
        }
    }

    @ViewBuilder
    private func experienceRow(for experience: ExperienceRecord) -> some View {
        HStack {
            Text(experience.name)

            Spacer()

            if let rating = experience.rating {
                Text(String(Double(rating) / 2))
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1))
        )
    }
}

#if DEBUG
#Preview("Success from spot IDs") {
    let dependencies = FakeSpotDetailViewModelDependencies {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in
            SpotInfoDetailed(spot: SpotRecord.peacePagoda, experiences: [])
        }
    }

    NavigationStack {
        SpotDetailView(
            dependencies: dependencies,
            spotId: SpotRecord.peacePagoda.id,
        )
        .environment(ThemeManager())
    }
}

#Preview("Preview data") {
    let dependencies = FakeSpotDetailViewModelDependencies {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { (_) async throws(SpotsRepositoryError) -> SpotInfoDetailed in
            try? await Task.sleep(nanoseconds: .max)
            throw SpotsRepositoryError.spotNotFound
        }
    }

    NavigationStack {
        SpotDetailView(
            dependencies: dependencies,
            spotInfoListing: SpotInfoSummary(spot: SpotRecord.peacePagoda),
        )
        .environment(ThemeManager())
    }
}
#endif
