import SwiftUI

extension Text {
    public func headlineTextStyling(using theme: ThemeTokens) -> some View {
        self
            .font(theme.headlineTextFont)
            .foregroundColor(theme.headlineTextColor)
    }

    public func captionTextStyling(using theme: ThemeTokens) -> some View {
        self
            .font(theme.captionTextFont)
            .foregroundColor(theme.captionTextColor)
    }
}
