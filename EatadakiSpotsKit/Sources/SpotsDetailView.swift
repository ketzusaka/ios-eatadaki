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
        spotInfoListing: SpotInfoListing,
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
    let dependencies = FakeSpotsDetailViewModelDependencies() {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { _ in
            Spot(
                id: UUID(),
                mapkitId: "I6FD7682FD36BB3BE",
                name: "Peace Pagoda",
                latitude: 37.7849447,
                longitude: -122.4303306,
                createdAt: .now,
            )
        }
    }
    
    NavigationStack {
        SpotsDetailView(
            dependencies: dependencies,
            spotIds: SpotIDs(mapkitId: "I6FD7682FD36BB3BE"),
        )
        .environment(ThemeManager())
    }
}

#Preview("Preview data") {
    let dependencies = FakeSpotsDetailViewModelDependencies() {
        $0.fakeSpotsRepository.stubFetchSpotWithIDs = { (_) async throws(SpotsRepositoryError) -> Spot in
            try? await Task.sleep(nanoseconds: .max)
            throw SpotsRepositoryError.spotNotFound
        }
    }
    
    NavigationStack {
        SpotsDetailView(
            dependencies: dependencies,
            spotInfoListing: SpotInfoListing(
                from: Spot(
                    id: UUID(),
                    mapkitId: "I6FD7682FD36BB3BE",
                    name: "Peace Pagoda",
                    latitude: 37.7849447,
                    longitude: -122.4303306,
                    createdAt: .now,
                )
            ),
        )
        .environment(ThemeManager())
    }
}
#endif
