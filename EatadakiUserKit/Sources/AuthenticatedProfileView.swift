import EatadakiUI
import SwiftUI

public struct AuthenticatedProfileView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        List {
            Text("Profile")
                .headlineTextStyling(using: theme)
        }
        .navigationTitle("Profile")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AuthenticatedProfileView()
            .environment(ThemeManager())
    }
}
#endif
