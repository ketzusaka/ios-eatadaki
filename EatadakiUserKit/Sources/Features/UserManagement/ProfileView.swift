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
