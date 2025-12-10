import SwiftUI

public struct ThemeTokens {
    // MARK: - Text Styles
    public let headlineTextFont: Font
    public let headlineTextColor: Color
    
    public init(
        headlineTextFont: Font,
        headlineTextColor: Color,
    ) {
        self.headlineTextFont = headlineTextFont
        self.headlineTextColor = headlineTextColor
    }
}
