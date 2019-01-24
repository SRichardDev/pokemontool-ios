
import UIKit
import MapKit

class SubmitViewController: UIViewController, MKMapViewDelegate, StoryboardInitialViewController {

    var firebaseConnector: FirebaseConnector!
    var locationOnMap: CLLocationCoordinate2D!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let viewRegion = MKCoordinateRegion(center: locationOnMap,
                                            latitudinalMeters: 120,
                                            longitudinalMeters: 120)
        mapView.setRegion(viewRegion, animated: false)
        
        let annotation = PokestopPointAnnotation(coordinate: locationOnMap)
        mapView.addAnnotation(annotation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameTextField.resignFirstResponder()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let pokestop = Pokestop(name: nameTextField.text!,
                                    latitude: locationOnMap.latitude,
                                    longitude: locationOnMap.longitude,
                                    submitter: firebaseConnector.user?.trainerName ?? "",
                                    id: "", quest: nil, upVotes: nil, downVotes: nil)
            
            firebaseConnector.savePokestop(pokestop)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let arena = Arena(name: nameTextField.text!,
                              latitude: locationOnMap.latitude,
                              longitude: locationOnMap.longitude,
                              submitter: firebaseConnector.user?.trainerName ?? "",
                              id: nil, upVotes: nil, downVotes: nil)
            firebaseConnector.saveArena(arena)
        }
        

        dismiss(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PokestopPointAnnotation  else { return nil }
        let annotationView = PokestopAnnotationView.prepareFor(mapView: mapView, annotation: annotation)
        return annotationView
    }
}
