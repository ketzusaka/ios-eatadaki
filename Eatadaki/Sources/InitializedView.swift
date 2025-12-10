import EatadakiKit
import EatadakiUI
import EatadakiSpotsKit
import SwiftUI

struct InitializedView: View {
    let context: InitializedContext
    let isAuthenticated: Bool

    var body: some View {
        TabView {
            SpotsView(
                viewModel: SpotsViewModel(
                    dependencies: context.dependencies,
                )
            )
            .tabItem {
                Label("Spots", systemImage: "mappin.circle")
            }

            ExperiencesView()
                .tabItem {
                    Label("Experiences", systemImage: "fork.knife")
                }

            ProfileView(isAuthenticated: isAuthenticated)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
