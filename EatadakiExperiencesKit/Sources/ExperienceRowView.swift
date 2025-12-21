import EatadakiData
import EatadakiUI
import SwiftUI

public struct ExperienceRowView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme

    private let experience: ExperienceInfoSummary

    public init(experience: ExperienceInfoSummary) {
        self.experience = experience
    }

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack(alignment: .leading, spacing: 4) {
            // First row: experience name on left, rating on right
            HStack {
                Text(experience.experience.name)
                    .listMainTextStyling(using: theme)

                Spacer()

                if let rating = experience.experience.rating {
                    RatingStarsView(rating: rating)
                }
            }

            // Second row: spot name in caption font on left, right side empty for now
            HStack {
                Text(experience.spot.name)
                    .captionTextStyling(using: theme)

                Spacer()
            }
        }
    }
}

#if DEBUG
#Preview {
    let experiences = [
        ExperienceInfoSummary(
            spot: SpotRecord.peacePagoda,
            experience: ExperienceRecord(
                id: UUID(),
                spotId: SpotRecord.peacePagoda.id,
                name: "Ramen",
                rating: 9,
                createdAt: .now,
            ),
        ),
        ExperienceInfoSummary(
            spot: SpotRecord.kinokuniya,
            experience: ExperienceRecord(
                id: UUID(),
                spotId: SpotRecord.kinokuniya.id,
                name: "Book Shopping",
                rating: 5,
                createdAt: .now,
            ),
        ),
        ExperienceInfoSummary(
            spot: SpotRecord.tsukijiMarket,
            experience: ExperienceRecord(
                id: UUID(),
                spotId: SpotRecord.tsukijiMarket.id,
                name: "Sushi Breakfast",
                rating: 2,
                createdAt: .now,
            ),
        ),
        ExperienceInfoSummary(
            spot: SpotRecord.shibuyaCrossing,
            experience: ExperienceRecord(
                id: UUID(),
                spotId: SpotRecord.shibuyaCrossing.id,
                name: "People Watching",
                rating: nil,
                createdAt: .now,
            ),
        ),
    ]

    List {
        ForEach(experiences, id: \.experience.id) { experience in
            ExperienceRowView(experience: experience)
        }
    }
    .environment(ThemeManager())
}
#endif
