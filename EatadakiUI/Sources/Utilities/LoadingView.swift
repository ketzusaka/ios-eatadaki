import SwiftUI

public struct LoadingView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    let text: String

    public init(text: String = "Loading...") {
        self.text = text
    }

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack {
            ProgressView()
            Text(text)
                .captionTextStyling(using: theme)
                .padding(.top, 8)
        }
    }
}

#if DEBUG
#Preview {
    LoadingView()
        .environment(ThemeManager())
}

#Preview("Custom Text") {
    LoadingView(text: "Fetching data...")
        .environment(ThemeManager())
}
#endif
