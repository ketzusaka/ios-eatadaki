import EatadakiData
import Foundation

public enum ExperienceDetailScreenData: Hashable {
    case id(UUID)
    case summary(ExperienceInfoSummary)
}
