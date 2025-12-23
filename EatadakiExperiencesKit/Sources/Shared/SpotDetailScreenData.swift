import EatadakiData
import Foundation

public enum SpotDetailScreenData: Hashable {
    case id(UUID)
    case summary(SpotInfoSummary)
}
