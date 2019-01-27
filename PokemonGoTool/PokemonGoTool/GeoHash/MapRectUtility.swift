
import MapKit

class MapRectUtility {
    
    class func getCoordinateFromMapRectangle(for x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint = MKMapPoint(x: x, y: y)
        return mapPoint.coordinate
    }
    
    class func getNorthEastCoordinate(in mapRect: MKMapRect) -> CLLocationCoordinate2D {
        return getCoordinateFromMapRectangle(for: mapRect.maxX, y: mapRect.origin.y)
    }
    
    class func getNorthWestCoordinate(in mapRect: MKMapRect) -> CLLocationCoordinate2D {
        return getCoordinateFromMapRectangle(for: mapRect.minX, y: mapRect.origin.y)
    }
    
    class func getSouthEastCoordinate(in mapRect: MKMapRect) -> CLLocationCoordinate2D {
        return getCoordinateFromMapRectangle(for: mapRect.maxX, y: mapRect.maxY)
    }
    
    class func getSouthWestCoordinate(in mapRect: MKMapRect) -> CLLocationCoordinate2D {
        return getCoordinateFromMapRectangle(for: mapRect.origin.x, y: mapRect.maxY)
    }
}
