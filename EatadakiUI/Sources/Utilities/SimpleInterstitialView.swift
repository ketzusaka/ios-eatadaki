import SwiftUI

public struct SimpleInterstitialView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme

    public enum Style {
        case notice
        case warning
        case critical
    }

    public enum ActionStyle {
        case primary
        case secondary
        case destructive
    }

    public struct Action: Hashable {
        public let label: String
        public let style: ActionStyle
        public let handler: () -> Void

        public init(label: String, style: ActionStyle, handler: @escaping () -> Void) {
            self.label = label
            self.style = style
            self.handler = handler
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(label)
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            lhs.label == rhs.label
        }
    }

    let title: String
    let description: String
    let imageSystemName: String
    let style: Style
    let actions: Set<Action>

    public init(
        title: String,
        description: String,
        imageSystemName: String,
        style: Style = .critical,
        actions: Set<Action> = []
    ) {
        self.title = title
        self.description = description
        self.imageSystemName = imageSystemName
        self.style = style
        self.actions = actions
    }

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: imageSystemName)
                    .font(.largeTitle)
                    .foregroundColor(color(for: style))

                Text(title)
                    .headlineTextStyling(using: theme)

                Text(description)
                    .captionTextStyling(using: theme)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            if !actions.isEmpty {
                HStack(spacing: 12) {
                    ForEach(sortedActions, id: \.self) { action in
                        actionButton(for: action)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }

    private var sortedActions: [Action] {
        actions.sorted { lhs, rhs in
            let lhsOrder = order(for: lhs.style)
            let rhsOrder = order(for: rhs.style)
            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }
            return lhs.label < rhs.label
        }
    }

    private func color(for style: Style) -> Color {
        switch style {
        case .notice: .blue
        case .warning: .yellow
        case .critical: .red
        }
    }

    private func order(for style: ActionStyle) -> Int {
        switch style {
        case .destructive: 0
        case .secondary: 1
        case .primary: 2
        }
    }

    @ViewBuilder
    private func actionButton(for action: Action) -> some View {
        let theme = themeManager.tokens(for: colorScheme)

        switch action.style {
        case .primary:
            Button(action: action.handler) {
                Text(action.label)
                    .frame(maxWidth: .infinity)
            }
            .primaryButtonStyling(using: theme)
        case .secondary:
            Button(action: action.handler) {
                Text(action.label)
                    .frame(maxWidth: .infinity)
            }
            .secondaryButtonStyling(using: theme)
        case .destructive:
            Button(action: action.handler) {
                Text(action.label)
                    .frame(maxWidth: .infinity)
            }
            .destructiveButtonStyling(using: theme)
        }
    }
}

#if DEBUG
#Preview("Critical") {
    SimpleInterstitialView(
        title: "Initialization Failed",
        description: "An error occurred while initializing the app. Please try again.",
        imageSystemName: "exclamationmark.triangle",
        style: .critical,
        actions: [
            SimpleInterstitialView.Action(label: "Delete", style: .destructive) {
                print("Delete tapped")
            },
            SimpleInterstitialView.Action(label: "Retry", style: .primary) {
                print("Retry tapped")
            },
            SimpleInterstitialView.Action(label: "Cancel", style: .secondary) {
                print("Cancel tapped")
            },
        ]
    )
    .environment(ThemeManager())
}

#Preview("Warning") {
    SimpleInterstitialView(
        title: "Warning",
        description: "This action may have unintended consequences.",
        imageSystemName: "exclamationmark.triangle.fill",
        style: .warning
    )
    .environment(ThemeManager())
}

#Preview("Notice") {
    SimpleInterstitialView(
        title: "Information",
        description: "Here's some helpful information for you.",
        imageSystemName: "info.circle",
        style: .notice
    )
    .environment(ThemeManager())
}
#endif
