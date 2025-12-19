import EatadakiData
import EatadakiLocationKit
import EatadakiUI
import MapKit
import SwiftUI

public typealias SpotsDetailViewDependencies = SpotsDetailViewModelDependencies

public struct SpotsDetailView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: SpotDetailViewModel

    public init(
        dependencies: SpotsDetailViewDependencies,
        spotInfoListing: SpotInfoSummary,
    ) {
        self.viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotIds: SpotIDs,
    ) {
        self.viewModel = SpotDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )
    }

    public var body: some View {
        ScrollView {
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
            case .loadingFailed:
                Text("Uh oh!")
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .onFirstAppear {
            await viewModel.initialize()
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
}

#if DEBUG
#Preview("Success from spot IDs") {
    let dependencies = FakeSpotDetailViewModelDependencies {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in SpotRecord.peacePagoda }
    }

    NavigationStack {
        SpotsDetailView(
            dependencies: dependencies,
            spotIds: SpotIDs(mapkitId: SpotRecord.peacePagoda.mapkitId),
        )
        .environment(ThemeManager())
    }
}

#Preview("Preview data") {
    let dependencies = FakeSpotDetailViewModelDependencies {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { (_) async throws(SpotsRepositoryError) -> SpotRecord in
            try? await Task.sleep(nanoseconds: .max)
            throw SpotsRepositoryError.spotNotFound
        }
    }

    NavigationStack {
        SpotsDetailView(
            dependencies: dependencies,
            spotInfoListing: SpotInfoSummary(spot: SpotRecord.peacePagoda),
        )
        .environment(ThemeManager())
    }
}
#endif
