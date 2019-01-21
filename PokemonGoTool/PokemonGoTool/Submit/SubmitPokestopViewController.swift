
import UIKit
import MapKit

class SubmitPokestopViewController: UIViewController, StoryboardInitialViewController {

    var firebaseConnector: FirebaseConnector!
    var locationOnMap: CLLocationCoordinate2D!
    @IBOutlet var pokestopNameTextField: UITextField!
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let pokestop = Pokestop(name: pokestopNameTextField.text!,
                                latitude: locationOnMap.latitude,
                                longitude: locationOnMap.longitude,
                                id: nil,
                                quest: nil)
        
        firebaseConnector.savePokestop(pokestop)
        dismiss(animated: true)
    }
}
