
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
        
    func setupMapButtonsMenu() {
        let registerPushGeohashButton = UIButton()
        registerPushGeohashButton.setImage(UIImage(named: "mapMenuPush"), for: .normal)
        registerPushGeohashButton.addAction { [weak self] in
            guard let self = self else { fatalError() }
            registerPushGeohashButton.scaleIn()
            
            guard let user = self.firebaseConnector.user else { return }
            self.isGeohashSelectionMode = true
            let subscribedGeohashPokestops = user.subscribedGeohashPokestops?.keys.sorted()
            NotificationBannerManager.shared.show(.pushRegistration)
            self.moveMapMenu(ConstraintConstants.mapMenuOffScreen)
            self.startGeohashRegistration(with: subscribedGeohashPokestops, submitClosure: {
                
            }, endClosure: { [weak self] in
                guard let self = self else { fatalError() }
                self.isGeohashSelectionMode = false
                self.moveMapMenu(ConstraintConstants.mapMenuOrigin)
                NotificationBannerManager.shared.dismiss()
            })
        }
        
        let newPoiButton = UIButton()
        newPoiButton.setImage(UIImage(named: "mapMenuCrosshair"), for: .normal)
        newPoiButton.addAction { [weak self] in
            newPoiButton.scaleIn()
            guard let self = self else { fatalError() }
            self.isPoiSubmissionMode = true
            NotificationBannerManager.shared.show(.addPoi)
            self.moveMapMenu(ConstraintConstants.mapMenuOffScreen)
            self.startPoiSubmission(submitClosure: { [weak self] in
                guard let self = self else { fatalError() }
                NotificationBannerManager.shared.dismiss()
                self.moveMapMenu(ConstraintConstants.mapMenuOrigin)
                let viewModel = SubmitViewModel(firebaseConnector: self.firebaseConnector,
                                                coordinate: self.poiSubmissionAnnotation.coordinate)
                self.coordinator?.showSubmitPokestopAndArena(for: viewModel)
            }, endClosure: { [weak self] in
                guard let self = self else { fatalError() }
                NotificationBannerManager.shared.dismiss()
                self.moveMapMenu(ConstraintConstants.mapMenuOrigin)
            })
        }
        
        let changeMapTypeButton = UIButton()
        changeMapTypeButton.setImage(UIImage(named: "mapMenuMap"), for: .normal)
        changeMapTypeButton.addAction { [weak self] in
            self?.changeMapType()
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
            let tappedGeohash = Geohash.encode(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            
            let foundOverlays = mapView.overlays.filter({$0.title == tappedGeohash})
            
            if foundOverlays.count > 0 {
                mapView.removeOverlays(foundOverlays)
                firebaseConnector.unsubscribeForPush(for: tappedGeohash)
            } else {
                addPolyLine(for: Geohash.geohashbox(tappedGeohash))
                firebaseConnector.subscribeForPush(for: tappedGeohash)
            }
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
