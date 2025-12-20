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

                HStack(spacing: starSpacing) {
                    ForEach(1...5, id: \.self) { starIndex in
                        starView(for: starIndex)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateRating(from: value.location)
                        }
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

    @ViewBuilder
    private func starView(for starIndex: Int) -> some View {
        // Star i represents ratings from (i-1)*2+1 to i*2
        // If rating >= i*2, fully filled
        // Else if rating >= (i-1)*2+1, half filled
        let fullThreshold = starIndex * 2
        let halfThreshold = (starIndex - 1) * 2 + 1

        let filledPortion: Double = if rating >= fullThreshold {
            1.0
        } else if rating >= halfThreshold {
            0.5
        } else {
            0.0
        }

        ZStack(alignment: .leading) {
            // Empty star background
            Image(systemName: "star")
                .resizable()
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: starSize, height: starSize)

            // Filled star overlay
            if filledPortion > 0 {
                Image(systemName: filledPortion >= 1.0 ? "star.fill" : "star.leadinghalf.filled")
                    .resizable()
                    .foregroundColor(.yellow)
                    .frame(width: starSize, height: starSize)
            }
        }
        .frame(width: starSize, height: starSize)
        .contentShape(Rectangle())
    }

    private func updateRating(from location: CGPoint) {
        let relativeX = location.x

        // Each star occupies starSize, with starSpacing between them
        // Star positions: 0 to starSize, (starSize + starSpacing) to (starSize * 2 + starSpacing), etc.
        var starIndex = 1
        var currentX: CGFloat = 0

        // Find which star the location is in
        while starIndex < 5 && relativeX >= currentX + starSize {
            currentX += starSize + starSpacing
            starIndex += 1
        }

        guard starIndex >= 1 && starIndex <= 5 else {
            return
        }

        // Calculate position within the current star
        let positionInStar = relativeX - currentX
        let clampedPosition = max(0, min(starSize, positionInStar))

        var newRating: Int
        if clampedPosition < starSize / 2 {
            // Left half of star = half star (odd rating: 1, 3, 5, 7, 9)
            newRating = (starIndex - 1) * 2 + 1
        } else {
            // Right half of star = full star (even rating: 2, 4, 6, 8, 10)
            newRating = starIndex * 2
        }

        // Clamp to valid range
        newRating = max(1, min(10, newRating))

        if rating != newRating {
            rating = newRating
        }
    }
}

#if DEBUG
#Preview {
    EditExperienceRatingView(rating: .constant(5), note: .constant(""))
        .environment(ThemeManager())
}
#endif
