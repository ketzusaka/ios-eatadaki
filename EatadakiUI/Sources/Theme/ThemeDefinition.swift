public struct ThemeDefinition {
    public let name: String
    public let lightTokens: ThemeTokens
    public let darkTokens: ThemeTokens

    public init(name: String, lightTokens: ThemeTokens, darkTokens: ThemeTokens) {
        self.name = name
        self.lightTokens = lightTokens
        self.darkTokens = darkTokens
    }

    public func tokens(for variant: ThemeVariant) -> ThemeTokens {
        switch variant {
        case .light:
            lightTokens
        case .dark:
            darkTokens
        }
    }
}
