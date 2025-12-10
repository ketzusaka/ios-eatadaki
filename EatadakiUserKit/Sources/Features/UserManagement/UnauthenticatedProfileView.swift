import SwiftUI
import EatadakiUI

public struct UnauthenticatedProfileView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    public init() {}
    
    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)
        
        List {
            Text("Please log in or register")
                .headlineTextStyling(using: theme)
        }
        .navigationTitle("Profile")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        UnauthenticatedProfileView()
            .environment(ThemeManager())
    }
}
#endif
