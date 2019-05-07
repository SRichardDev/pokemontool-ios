
import MapKit

protocol MapRegionSetable {
    var mapView: MKMapView! { get set }
}

extension MapRegionSetable {
    
    func setMapRegion(distance: Int, coordinate: CLLocationCoordinate2D? = nil) {
        let viewRegion = MKCoordinateRegion(center: coordinate ?? mapView.centerCoordinate,
                                            latitudinalMeters: CLLocationDistance(distance),
                                            longitudinalMeters: CLLocationDistance(distance))
        mapView.setRegion(viewRegion, animated: true)
    }
}
