import EatadakiData
import EatadakiKit
import EatadakiUI
import EatadakiSpotsKit
import EatadakiExperiencesKit
import EatadakiUserKit
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

#if DEBUG
#Preview("Unauthenticated") {
    let context = InitializedContext(
        experiencesDataService: FakeExperiencesDataService(),
        deviceConfigDataService: FakeDeviceConfigDataService(),
        userDataService: FakeUserDataService(),
    )
    
    InitializedView(context: context, isAuthenticated: false)
        .environment(ThemeManager())
}

#Preview("Authenticated") {
    let fakeUserDataService = FakeUserDataService {
        $0.stubUserRepository = FakeUserRepository {
            $0.stubFetchUser = {
                User(id: UUID(), email: "test@example.com", createdAt: .now)
            }
        }
    }
    
    let context = InitializedContext(
        experiencesDataService: FakeExperiencesDataService(),
        deviceConfigDataService: FakeDeviceConfigDataService(),
        userDataService: fakeUserDataService,
    )
    
    InitializedView(context: context, isAuthenticated: true)
        .environment(ThemeManager())
}
#endif
