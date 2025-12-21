import Foundation

#if DEBUG
public extension SpotRecord {
    static let peacePagoda = SpotRecord(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        mapkitId: "I6FD7682FD36BB3BE",
        name: "Peace Pagoda",
        latitude: 37.7849447,
        longitude: -122.4303306,
        createdAt: Date(timeIntervalSince1970: 0),
    )

    static let kinokuniya = SpotRecord(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        mapkitId: "IBB934C01F6A585EA",
        name: "Kinokuniya",
        latitude: 37.7849544,
        longitude: -122.4317274,
        createdAt: Date(timeIntervalSince1970: 0),
    )

    static let tsukijiMarket = SpotRecord(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        mapkitId: nil,
        name: "Tsukiji Market",
        latitude: 35.6654,
        longitude: 139.7706,
        createdAt: Date(timeIntervalSince1970: 0),
    )

    static let shibuyaCrossing = SpotRecord(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        mapkitId: nil,
        name: "Shibuya Crossing",
        latitude: 35.6598,
        longitude: 139.7006,
        createdAt: Date(timeIntervalSince1970: 0),
    )
}
#endif

