
import MapKit

protocol GeohashRegisterable: class {
    var mapView: MKMapView! { get set }
    var polygon: MKPolygon? { get set }
    var isGeohashSelectionMode: Bool { get set }
}

extension GeohashRegisterable where Self: UIViewController & BottomMenuShowable & MapRegionSetable {
    
    func startGeohashRegistration(with currentGeohashes: [String]?,
                                  submitClosure: @escaping () -> Void,
                                  endClosure: @escaping () -> Void) {
        
        tabBarController?.tabBar.isHidden = true
        
        setMapRegion(distance: 3000)
        currentGeohashes?.forEach { addPolyLine(for: Geohash.geohashbox($0)) }
        
        let submitButton = CircleButton(type: .custom)
        submitButton.type = .accept
        submitButton.addAction {
            submitButton.scaleIn()
            submitClosure()
        }
        
        let cancelButton = CircleButton(type: .custom)
        cancelButton.type = .cancel
        cancelButton.addAction {
            cancelButton.scaleIn()
            self.endGeohashRegistration()
            endClosure()
        }
        
        let menuView = showBottomMenu([cancelButton, submitButton])
        menuView.tag = ViewTags.geohashRegistrationStackView
    }
    
    func endGeohashRegistration() {
        tabBarController?.tabBar.isHidden = false
        guard let stackView = view.viewWithTag(ViewTags.geohashRegistrationStackView) else { return }
        UIView.animate(withDuration: 0.25, animations: {stackView.alpha = 0}) { _ in stackView.removeFromSuperview() }
        mapView.removeOverlays(mapView.overlays)
    }
    
    func addPolyLine(for geohashBox: GeohashBox?) {
        guard let geohashBox = geohashBox else { return }
        let polyLine = MKPolyline.polyline(for: geohashBox)
        let polygon = MKPolygon.polygon(for: geohashBox)
        self.polygon = polygon
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)
    }
}
