
import UIKit
import MapKit

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
            NotificationBannerManager.shared.show(.pushRegistration)
        } else {
            NotificationBannerManager.shared.dismiss()
        }
    }
    
    func setupMapButtonsMenu() {
        let registerPushGeohashButton = UIButton()
        registerPushGeohashButton.setImage(UIImage(named: "mapMenuPush"), for: .normal)
        registerPushGeohashButton.addAction { [weak self] in
            self?.togglePushRegistrationMode()
            registerPushGeohashButton.scaleIn()
        }
        
        let newPoiButton = UIButton()
        newPoiButton.setImage(UIImage(named: "mapMenuCrosshair"), for: .normal)
        newPoiButton.addAction { [weak self] in
            newPoiButton.scaleIn()
            guard let self = self else { return }
            self.poiSubmissionMode = true
            
            NotificationBannerManager.shared.show(.addPoi)
            
            self.moveMapMenu(-500)
            UIView.animate(withDuration: 0.25, animations: {self.view.layoutIfNeeded()})
            self.startPoiSubmission(submitClosure: {
                NotificationBannerManager.shared.dismiss()
                self.moveMapMenu(15)
                let viewModel = SubmitViewModel(firebaseConnector: self.firebaseConnector,
                                                coordinate: self.poiSubmissionAnnotation.coordinate)
                self.coordinator?.showSubmitPokestopAndArena(for: viewModel)
            }, endClosure: {
                NotificationBannerManager.shared.dismiss()
                self.moveMapMenu(15)
            })
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
        
        let filterButton = UIButton()
        filterButton.setImage(UIImage(named: "filter"), for: .normal)
        filterButton.addAction { [weak self] in
            self?.coordinator?.showMapFilter()
            filterButton.scaleIn()
        }
        
        ButtonsStackViewController.embed(in: settingsButtonsView,
                                         in: self,
                                         with: [registerPushGeohashButton,
                                                newPoiButton,
                                                changeMapTypeButton,
                                                locateButton,
                                                filterButton])
    }
    
    
    private func moveMapMenu(_ constant: CGFloat) {
        self.view.constraints.first { $0.identifier == ConstraintIdentifiers.settingsMenuRightConstraint}?.constant = constant
        UIView.animate(withDuration: 0.25, animations: {self.view.layoutIfNeeded()})
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
