import SwiftUI

public struct ThemeTokens {
    // MARK: - Text Styles
    public let headlineTextFont: Font
    public let headlineTextColor: Color
    public let captionTextFont: Font
    public let captionTextColor: Color

    // MARK: - Button Styles
    public let primaryButtonTint: Color
    public let secondaryButtonTint: Color
    public let destructiveButtonTint: Color

    public init(
        headlineTextFont: Font,
        headlineTextColor: Color,
        captionTextFont: Font,
        captionTextColor: Color,
        primaryButtonTint: Color,
        secondaryButtonTint: Color,
        destructiveButtonTint: Color,
    ) {
        self.headlineTextFont = headlineTextFont
        self.headlineTextColor = headlineTextColor
        self.captionTextFont = captionTextFont
        self.captionTextColor = captionTextColor
        self.primaryButtonTint = primaryButtonTint
        self.secondaryButtonTint = secondaryButtonTint
        self.destructiveButtonTint = destructiveButtonTint
    }
}
