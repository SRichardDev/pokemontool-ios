
import UIKit
import MapKit

enum SubmitType {
    case pokestop
    case arena(isEX: Bool?)
}

struct SubmitContent {
    var location: CLLocationCoordinate2D?
    var name: String?
    var submitType: SubmitType!
}

class SubmitViewController: UIViewController, StoryboardInitialViewController, SubmitMapEmbeddable {

    var firebaseConnector: FirebaseConnector!
    var locationOnMap: CLLocationCoordinate2D!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var containerView: UIView!
    var mapViewController: SubmitMapViewController!
    var submitType: SubmitType = .pokestop
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Neuer Pokéstop"
        mapViewController = embedMap(coordinate: locationOnMap)
    }

    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            submitType = .pokestop
            mapViewController.addPokestopAnnotation()
            title = "Neuer Pokéstop"
        } else if sender.selectedSegmentIndex == 1 {
            submitType = .arena(isEX: false)
            mapViewController.addArenaAnnotation()
            title = "Neue Arena"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SubmitNameViewController {
            let submitContent = SubmitContent(location: mapViewController.locationOnMap, name: nil, submitType: submitType)
            destination.submitContent = submitContent
            destination.firebaseConnector = firebaseConnector
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
