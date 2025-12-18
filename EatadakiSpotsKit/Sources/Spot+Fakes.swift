import EatadakiData
import Foundation

#if DEBUG
public extension Spot {
    static let peacePagoda = Spot(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        mapkitId: "I6FD7682FD36BB3BE",
        name: "Peace Pagoda",
        latitude: 37.7849447,
        longitude: -122.4303306,
        createdAt: Date(timeIntervalSince1970: 0),
    )

    static let kinokuniya = Spot(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        mapkitId: "IBB934C01F6A585EA",
        name: "Kinokuniya",
        latitude: 37.7849544,
        longitude: -122.4317274,
        createdAt: Date(timeIntervalSince1970: 0),
    )
}
#endif
