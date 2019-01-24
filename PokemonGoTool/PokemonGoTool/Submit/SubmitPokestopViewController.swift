
import UIKit
import MapKit

class SubmitPokestopViewController: UIViewController, MKMapViewDelegate, StoryboardInitialViewController {

    var firebaseConnector: FirebaseConnector!
    var locationOnMap: CLLocationCoordinate2D!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var pokestopNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let viewRegion = MKCoordinateRegion(center: locationOnMap,
                                            latitudinalMeters: 150,
                                            longitudinalMeters: 150)
        mapView.setRegion(viewRegion, animated: false)
        
        let annotation = PokestopPointAnnotation(coordinate: locationOnMap)
        mapView.addAnnotation(annotation)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let pokestop = Pokestop(name: pokestopNameTextField.text!,
                                latitude: locationOnMap.latitude,
                                longitude: locationOnMap.longitude,
                                submitter: firebaseConnector.user?.trainerName ?? "",
                                id: nil, quest: nil, upVotes: nil, downVotes: nil)
        
        firebaseConnector.savePokestop(pokestop)
        dismiss(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PokestopPointAnnotation  else { return nil }
        let annotationView = PokestopAnnotationView.prepareFor(mapView: mapView, annotation: annotation)
        return annotationView
    }
}
