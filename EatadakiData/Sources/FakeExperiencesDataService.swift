#if DEBUG
import Foundation

public class FakeExperiencesDataService: ExperiencesDataService {
    public init(_ configure: (FakeExperiencesDataService) -> Void = { _ in }) {
        configure(self)
    }

    public private(set) var invokedCountSpotsRepository: Int = 0
    public var stubSpotsRepository: SpotsRepository = FakeSpotsRepository()

    public var spotsRepository: SpotsRepository {
        invokedCountSpotsRepository += 1
        return stubSpotsRepository
    }
}
#endif
