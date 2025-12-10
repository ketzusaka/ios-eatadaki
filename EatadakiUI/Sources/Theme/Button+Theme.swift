import SwiftUI

extension Button {
    public func primaryButtonStyling(using theme: ThemeTokens) -> some View {
        self
            .buttonStyle(.borderedProminent)
            .tint(theme.primaryButtonTint)
    }
    
    public func secondaryButtonStyling(using theme: ThemeTokens) -> some View {
        self
            .buttonStyle(.bordered)
            .tint(theme.secondaryButtonTint)
    }
    
    public func destructiveButtonStyling(using theme: ThemeTokens) -> some View {
        self
            .buttonStyle(.bordered)
            .tint(theme.destructiveButtonTint)
    }
}
