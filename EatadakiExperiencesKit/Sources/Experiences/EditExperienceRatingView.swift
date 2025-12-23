import EatadakiUI
import SwiftUI

public struct EditExperienceRatingView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme

    @Binding var rating: Int // 1-10, where 1 = 0.5 stars, 10 = 5.0 stars
    @Binding var note: String // Optional note (empty string when no note)

    private let starSize: CGFloat = 48
    private let starSpacing: CGFloat = 8

    public init(rating: Binding<Int>, note: Binding<String>) {
        self._rating = rating
        self._note = note
    }

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Stars")
                    .headlineTextStyling(using: theme)

                RatingStarsView(
                    rating: $rating,
                    starSize: starSize,
                    starSpacing: starSpacing,
                )

                Text("Check out our **rating guide** for tips on how we think about ratings. With our system we eliminate the guesswork of rating by tying stars to behavior.")
                    .captionTextStyling(using: theme)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Note")
                    .headlineTextStyling(using: theme)

                TextEditor(text: $note)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                Text("A note is optional.")
                    .captionTextStyling(using: theme)
            }
        }
    }
}

#if DEBUG
#Preview {
    EditExperienceRatingView(rating: .constant(5), note: .constant(""))
        .environment(ThemeManager())
}
#endif
