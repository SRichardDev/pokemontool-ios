
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
    
        NotificationBannerManager.shared.show(.pushRegistration)
        setMapRegion(distance: 3500, animated: true)
        
        let submitButton = CircleButton(type: .custom)
        submitButton.type = .accept
        submitButton.addAction {
            submitButton.scaleIn()
            self.endGeohashRegistration()
            submitClosure()
        }
        
        let cancelButton = CircleButton(type: .custom)
        cancelButton.type = .trash
        cancelButton.addAction {
            cancelButton.scaleIn()
            self.deleteAllRegisteredGeohashes()
        }
        
        let menuView = showBottomMenu([cancelButton, submitButton])
        menuView.tag = ViewTags.geohashRegistrationStackView
        
        mapView.annotations.forEach({ self.mapView.view(for: $0)?.isUserInteractionEnabled = false })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentGeohashes?.forEach { self.addPolyLine(for: Geohash.geohashbox($0)) }
        }
    }
    
    func endGeohashRegistration() {
        NotificationBannerManager.shared.dismiss()
        guard let stackView = view.viewWithTag(ViewTags.geohashRegistrationStackView) else { return }
        UIView.animate(withDuration: 0.25, animations: {stackView.alpha = 0}) { _ in stackView.removeFromSuperview() }
        mapView.removeOverlays(mapView.overlays)
        mapView.annotations.forEach({ self.mapView.view(for: $0)?.isUserInteractionEnabled = true })
    }
    
    func deleteAllRegisteredGeohashes() {
        #warning("TODO: Delete all registered Geohashes from the server")
    }
    
    func addPolyLine(for geohashBox: GeohashBox?) {
        guard let geohashBox = geohashBox else { return }
        let polyLine = MKPolyline.polyline(for: geohashBox)
        polyLine.title = geohashBox.hash
        let polygon = MKPolygon.polygon(for: geohashBox)
        polygon.title = geohashBox.hash
        self.polygon = polygon
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)
    }
}
