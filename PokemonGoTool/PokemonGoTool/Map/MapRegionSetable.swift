
import MapKit

protocol MapRegionSetable {
    var mapView: MKMapView! { get set }
}

extension MapRegionSetable {
    
    func setMapRegion(distance: Int) {
        let viewRegion = MKCoordinateRegion(center: mapView.centerCoordinate,
                                            latitudinalMeters: CLLocationDistance(distance),
                                            longitudinalMeters: CLLocationDistance(distance))
        mapView.setRegion(viewRegion, animated: true)
    }
}
