import EatadakiUI
import SwiftUI

public struct ExperiencesView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        NavigationStack {
            List {
                Text("Experiences")
                    .headlineTextStyling(using: theme)
            }
            .navigationTitle("Experiences")
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ExperiencesView()
            .environment(ThemeManager())
    }
}
#endif
