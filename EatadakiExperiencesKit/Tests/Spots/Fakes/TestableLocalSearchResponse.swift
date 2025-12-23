import MapKit

#if DEBUG
extension MKLocalSearch {
    public class TestableResponse: Response {
        public var stubMapItems: [MKMapItem]?
        public var stubBoundingRegion: MKCoordinateRegion?

        public init(_ builder: ((MKLocalSearch.TestableResponse) -> Void)? = nil) {
            super.init()
            builder?(self)
        }

        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public var mapItems: [MKMapItem] {
            stubMapItems ?? super.mapItems
        }

        override public var boundingRegion: MKCoordinateRegion {
            stubBoundingRegion ?? super.boundingRegion
        }
    }
}
#endif
