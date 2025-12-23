import EatadakiExperiencesKit
import MapKit
import Testing

@Suite("MapKitLocalSearchRequestProvider Tests")
struct MapKitLocalSearchRequestProviderTests {
    @Test("createSearch returns MKLocalSearch instance")
    func testCreateSearchReturnsMKLocalSearch() {
        let provider = MapKitLocalSearchRequestProvider()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"

        let result = provider.createSearch(request: request)

        #expect(result is MKLocalSearch)
    }

    @Test("createSearch returns LocalSearch conforming instance")
    func testCreateSearchReturnsLocalSearch() {
        let provider = MapKitLocalSearchRequestProvider()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "cafe"

        let result = provider.createSearch(request: request)

        #expect(result is MKLocalSearch)
    }

    @Test("createSearch returns different instances for different requests")
    func testCreateSearchReturnsDifferentInstances() {
        let provider = MapKitLocalSearchRequestProvider()
        let request1 = MKLocalSearch.Request()
        request1.naturalLanguageQuery = "restaurant"

        let request2 = MKLocalSearch.Request()
        request2.naturalLanguageQuery = "cafe"

        let result1 = provider.createSearch(request: request1)
        let result2 = provider.createSearch(request: request2)

        // They should be different instances
        #expect(result1 !== result2)
    }

    @Test("createSearch can be called multiple times")
    func testCreateSearchCanBeCalledMultipleTimes() {
        let provider = MapKitLocalSearchRequestProvider()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "bakery"

        let result1 = provider.createSearch(request: request)
        let result2 = provider.createSearch(request: request)

        #expect(result1 is MKLocalSearch)
        #expect(result2 is MKLocalSearch)
        #expect(result1 !== result2)
    }
}
