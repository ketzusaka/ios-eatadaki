import EatadakiKit
import EatadakiUI
import SwiftUI

struct InitializedView: View {
    let context: InitializedContext
    let isAuthenticated: Bool

    var body: some View {
        TabView {
            SpotsView(
                viewModel: SpotsViewModel(
                    dependencies: context,
                )
            )
            .tabItem {
                Label("Spots", systemImage: "mappin.circle")
            }

            TastesView()
                .tabItem {
                    Label("Tastes", systemImage: "fork.knife")
                }

            ProfileView(isAuthenticated: isAuthenticated)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
