import EatadakiData
import EatadakiLocationKit
import EatadakiUI
import SwiftUI

public struct SpotsView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme
    @Bindable var viewModel: SpotsViewModel

    public init(viewModel: SpotsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        NavigationStack {
            List {
                Text("Spots")
                    .headlineTextStyling(using: theme)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // TODO: Present Filtering UI
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    })
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Add spot
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .navigationTitle("Spots")
        }
    }
}

#if DEBUG
#Preview {
    let dependencies = FakeSpotsViewModelDependencies()
    let viewModel = SpotsViewModel(dependencies: dependencies)

    NavigationStack {
        SpotsView(viewModel: viewModel)
            .environment(ThemeManager())
    }
}
#endif
