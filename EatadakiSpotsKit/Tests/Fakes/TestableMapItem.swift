import MapKit

#if DEBUG
public class TestableMapItem: MKMapItem {
    public var stubIdentifier: MKMapItem.Identifier?
    public var stubLocation: CLLocation?

    public init(_ builder: ((TestableMapItem) -> Void)? = nil) {
        super.init()
        builder?(self)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var location: CLLocation {
        stubLocation ?? super.location
    }

    override public var identifier: MKMapItem.Identifier? {
        stubIdentifier ?? super.identifier
    }
}
#endif
