
import UIKit
import MapKit
import NotificationBannerSwift

extension MapViewController {
    func zoomToLocationFromPushIfNeeded() {
        guard let mapRegionFromPush = mapRegionFromPush else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.mapView.setRegion(mapRegionFromPush, animated: true)
            self.mapRegionFromPush = nil
        }
    }
    
    private func togglePushRegistrationMode() {
        self.isGeohashSelectionMode = !self.isGeohashSelectionMode
        if self.isGeohashSelectionMode {
            let banner = NotificationBanner(title: "Push Registrierung",
                                            subtitle: "Wähle den Bereich aus für den du Benachrichtigt werden möchtest",
                                            style: .info)
            banner.show()
        }
    }
    
    private func toggleAnnotationSubmitMode() {
        let banner = NotificationBanner(title: "Pokéstop / Arena hinzufügen",
                                        subtitle: "Benutze das Fadenkreuz um die Position zu markieren",
                                        style: .warning)
        banner.show()
        
        
    }
    
    func setupMapButtonsMenu() {
        let registerPushGeohashButton = UIButton()
        registerPushGeohashButton.setImage(UIImage(named: "mapMenuPush"), for: .normal)
        registerPushGeohashButton.addAction { [weak self] in
            self?.togglePushRegistrationMode()
            registerPushGeohashButton.scaleIn()
        }
        
        let newAnnotationButton = UIButton()
        newAnnotationButton.setImage(UIImage(named: "mapMenuCrosshair"), for: .normal)
        newAnnotationButton.addAction { [weak self] in
            self?.mapCrosshairView.startAnimating()
            newAnnotationButton.scaleIn()
            self?.toggleAnnotationSubmitMode()
        }
        
        let changeMapTypeButton = UIButton()
        changeMapTypeButton.setImage(UIImage(named: "mapMenuMap"), for: .normal)
        changeMapTypeButton.addAction { [weak self] in
            self?.changeMapTypeAnimated()
            changeMapTypeButton.scaleIn()
        }
        
        let locateButton = UIButton()
        locateButton.setImage(UIImage(named: "mapMenuLocate"), for: .normal)
        locateButton.addAction { [weak self] in
            self?.zoomToUserLocation(animated: true)
            locateButton.scaleIn()
        }
        
        ButtonsStackViewController.embed(in: settingsButtonsView,
                                         in: self,
                                         with: [registerPushGeohashButton,
                                                newAnnotationButton,
                                                changeMapTypeButton,
                                                locateButton])
    }
    
    @IBAction func longPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let viewModel = SubmitViewModel(firebaseConnector: firebaseConnector, coordinate: locationOnMap)
            coordinator?.showSubmitPokestopAndArena(for: viewModel)
        }
    }
    
    @IBAction func tappedMap(_ sender: UITapGestureRecognizer) {
        if isGeohashSelectionMode {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let geohash = Geohash.encode(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            firebaseConnector.subscribeForPush(for: geohash)
            addPolyLine(for: Geohash.geohashbox(geohash))
        }
    }
    
    func zoomToUserLocation(animated: Bool = false) {
        if let userLocation = locationManager.currentUserLocation {
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 500,
                                                longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: animated)
        }
    }
}
