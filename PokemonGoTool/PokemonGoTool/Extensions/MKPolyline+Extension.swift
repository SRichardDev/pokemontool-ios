import UIKit
import MapKit

extension MKPolyline {
    class func polyline(for geohashBox: GeohashBox) -> MKPolyline {
        let nw = CLLocation(latitude: geohashBox.north, longitude: geohashBox.west)
        let ne = CLLocation(latitude: geohashBox.north, longitude: geohashBox.east)
        let se = CLLocation(latitude: geohashBox.south, longitude: geohashBox.east)
        let sw = CLLocation(latitude: geohashBox.south, longitude: geohashBox.west)
        
        let locationCoordinates = [nw,ne,se,sw,nw]
        let coordinates = locationCoordinates.map { $0.coordinate }
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        return polyLine
    }
}

extension MKPolygon {
    class func polygon(for geohashBox: GeohashBox) -> MKPolygon {
        let nw = CLLocation(latitude: geohashBox.north, longitude: geohashBox.west)
        let ne = CLLocation(latitude: geohashBox.north, longitude: geohashBox.east)
        let se = CLLocation(latitude: geohashBox.south, longitude: geohashBox.east)
        let sw = CLLocation(latitude: geohashBox.south, longitude: geohashBox.west)
        
        let locationCoordinates = [nw,ne,se,sw,nw]
        let coordinates = locationCoordinates.map { $0.coordinate }
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        return polygon
    }
}
