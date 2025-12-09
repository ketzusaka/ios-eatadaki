import SwiftUI

public struct SpotsView: View {
    @Bindable var viewModel: SpotsViewModel

    public init(viewModel: SpotsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            List {
                Text("Spots")
                    .font(.headline)
            }
            .navigationTitle("Eatadaki")
        }
    }
}
