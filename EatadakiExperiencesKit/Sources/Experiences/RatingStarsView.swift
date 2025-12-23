import SwiftUI

public struct RatingStarsView: View {
    @Binding private var rating: Int
    private let starSize: CGFloat
    private let starSpacing: CGFloat

    public init(
        rating: Binding<Int>,
        starSize: CGFloat = 12,
        starSpacing: CGFloat = 2,
    ) {
        self._rating = rating
        self.starSize = starSize
        self.starSpacing = starSpacing
    }

    public init(
        rating: Int,
        starSize: CGFloat = 12,
        starSpacing: CGFloat = 2,
    ) {
        self._rating = .constant(rating)
        self.starSize = starSize
        self.starSpacing = starSpacing
    }

    public var body: some View {
        HStack(spacing: starSpacing) {
            ForEach(1...5, id: \.self) { starIndex in
                starView(for: starIndex)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateRating(from: value.location)
                }
        )
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
    VStack(spacing: 20) {
        RatingStarsView(rating: 1)
        RatingStarsView(rating: 3)
        RatingStarsView(rating: 5)
        RatingStarsView(rating: 7)
        RatingStarsView(rating: 9)
        RatingStarsView(rating: 10)

        Divider()

        RatingStarsView(rating: 5, starSize: 48, starSpacing: 8)
    }
    .padding()
}
#endif
