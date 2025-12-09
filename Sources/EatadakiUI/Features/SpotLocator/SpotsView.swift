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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // TODO: Present Filtering UI
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Add spot
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Spots")
        }
    }
}
