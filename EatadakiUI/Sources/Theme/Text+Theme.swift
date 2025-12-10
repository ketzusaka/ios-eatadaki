import SwiftUI

extension Text {
    public func headlineTextStyling(using theme: ThemeTokens) -> some View {
        font(theme.headlineTextFont)
            .foregroundColor(theme.headlineTextColor)
    }
}
