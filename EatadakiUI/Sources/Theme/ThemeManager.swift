import SwiftUI
import Observation

@Observable
public class ThemeManager {
        
    public let themeDefinition: ThemeDefinition
    
    public init(themeDefinition: ThemeDefinition = .eatadaki) {
        self.themeDefinition = themeDefinition
    }

    public func tokens(for variant: ThemeVariant) -> ThemeTokens {
        themeDefinition.tokens(for: variant)
    }

    public func tokens(for colorScheme: ColorScheme) -> ThemeTokens {
        tokens(for: colorScheme == .dark ? ThemeVariant.dark : ThemeVariant.light)
    }

}

// MARK: - Default Theme

extension ThemeDefinition {
    public static let eatadaki = ThemeDefinition(
        name: "Eatadaki",
        lightTokens: ThemeTokens(
            headlineTextFont: .headline,
            headlineTextColor: .black,
            captionTextFont: .caption,
            captionTextColor: .secondary,
            primaryButtonTint: .blue,
            secondaryButtonTint: .gray,
            destructiveButtonTint: .red
        ),
        darkTokens: ThemeTokens(
            headlineTextFont: .headline,
            headlineTextColor: .white,
            captionTextFont: .caption,
            captionTextColor: .secondary,
            primaryButtonTint: .blue,
            secondaryButtonTint: .gray,
            destructiveButtonTint: .red
        )
    )
}
