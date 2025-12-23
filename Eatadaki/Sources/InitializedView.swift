import EatadakiData
import EatadakiExperiencesKit
import EatadakiKit
import EatadakiUI
import EatadakiUserKit
import SwiftUI

struct InitializedView: View {
    let context: InitializedContext

    var body: some View {
        TabView {
            SpotsView(
                dependencies: context,
            )
            .tabItem {
                Label("Spots", systemImage: "mappin.circle")
            }

            ExperiencesView(
                dependencies: context,
            )
                .tabItem {
                    Label("Experiences", systemImage: "fork.knife")
                }

            ProfileView(isAuthenticated: false)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#if DEBUG
#Preview("Unauthenticated") {
    let userDataService = FakeUserDataService()
    let context = InitializedContext(
        deviceConfigDataService: FakeDeviceConfigDataService(),
        experiencesDataService: FakeExperiencesDataService(),
        userController: UserController(userRepository: userDataService.userRepository, user: nil),
        userDataService: userDataService,
    )

    InitializedView(context: context)
        .environment(ThemeManager())
}

#Preview("Authenticated") {
    let fakeUser = UserRecord(id: UUID(), email: "test@example.com", createdAt: .now)
    let fakeUserDataService = FakeUserDataService {
        $0.stubUserRepository = FakeUserRepository {
            $0.stubFetchUser = { fakeUser }
        }
    }

    let context = InitializedContext(
        deviceConfigDataService: FakeDeviceConfigDataService(),
        experiencesDataService: FakeExperiencesDataService(),
        userController: UserController(userRepository: fakeUserDataService.userRepository, user: fakeUser),
        userDataService: fakeUserDataService,
    )

    InitializedView(context: context)
        .environment(ThemeManager())
}
#endif
