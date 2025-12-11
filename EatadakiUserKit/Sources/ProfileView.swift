import EatadakiUI
import SwiftUI

public struct ProfileView: View {
    let isAuthenticated: Bool

    public init(isAuthenticated: Bool) {
        self.isAuthenticated = isAuthenticated
    }

    public var body: some View {
        NavigationStack {
            if isAuthenticated {
                AuthenticatedProfileView()
            } else {
                UnauthenticatedProfileView()
            }
        }
    }
}

#if DEBUG
#Preview("Authenticated") {
    ProfileView(isAuthenticated: true)
        .environment(ThemeManager())
}

#Preview("Unauthenticated") {
    ProfileView(isAuthenticated: false)
        .environment(ThemeManager())
}
#endif
