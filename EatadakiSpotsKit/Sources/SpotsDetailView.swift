import EatadakiData
import EatadakiLocationKit
import EatadakiUI
import MapKit
import SwiftUI

public typealias SpotsDetailViewDependencies = SpotsDetailViewModelDependencies

public struct SpotsDetailView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: SpotsDetailViewModel

    public init(
        dependencies: SpotsDetailViewDependencies,
        spotInfoListing: SpotInfoSummary,
    ) {
        self.viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotInfoListing: spotInfoListing,
        )
    }

    public init(
        dependencies: SpotsDetailViewModelDependencies,
        spotIds: SpotIDs,
    ) {
        self.viewModel = SpotsDetailViewModel(
            dependencies: dependencies,
            spotIds: spotIds,
        )
    }

    public var body: some View {
        VStack {
            switch viewModel.stage {
            case .uninitialized, .initializing:
                if let preview = viewModel.preview {
                    mapView(name: preview.name, coordinates: preview.coordinates)

                    LoadingView()
                    Spacer()
                } else {
                    LoadingView()
                }
            case .loaded(let spotInfoDetail):
                mapView(name: spotInfoDetail.name, coordinates: spotInfoDetail.coordinates)
                Spacer()
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
    let dependencies = FakeSpotsDetailViewModelDependencies {
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
    let dependencies = FakeSpotsDetailViewModelDependencies {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { (_) async throws(SpotsRepositoryError) -> SpotRecord in
            try? await Task.sleep(nanoseconds: .max)
            throw SpotsRepositoryError.spotNotFound
        }
    }

    NavigationStack {
        SpotsDetailView(
            dependencies: dependencies,
            spotInfoListing: SpotInfoSummary(from: SpotRecord.peacePagoda),
        )
        .environment(ThemeManager())
    }
}
#endif
