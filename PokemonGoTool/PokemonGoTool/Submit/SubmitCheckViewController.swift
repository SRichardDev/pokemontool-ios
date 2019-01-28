
import UIKit

class SubmitCheckViewController: UIViewController, SubmitMapEmbeddable {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    var submitContent: SubmitContent?
    var firebaseConnector: FirebaseConnector!
    var mapViewController: SubmitMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let name = submitContent?.name else { return }
        guard let location = submitContent?.location else { return }
        mapViewController = embedMap(coordinate: location)
        
        guard let submitType = submitContent?.submitType else { return }
        switch submitType {
        case .pokestop:
            mapViewController.addPokestopAnnotation()
            nameLabel.text = "Pokéstop: \(name)"
        case .arena:
            mapViewController.addArenaAnnotation()
            nameLabel.text = "Arena: \(name)"
        }
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        guard let name = submitContent?.name else {return}
        guard let coordinate = submitContent?.location else {return}
        guard let submitType = submitContent?.submitType else { return }
        switch submitType {
        case .pokestop:
            let pokestop = Pokestop(name: name,
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude,
                                    submitter: firebaseConnector.user?.trainerName ?? "",
                                    id: "", quest: nil, upVotes: nil, downVotes: nil)
            
            firebaseConnector.savePokestop(pokestop)

        case .arena:
            let arena = Arena(name: name,
                              latitude: coordinate.latitude,
                              longitude: coordinate.longitude,
                              submitter: firebaseConnector.user?.trainerName ?? "",
                              id: nil, upVotes: nil, downVotes: nil)
            firebaseConnector.saveArena(arena)

        }
        dismiss(animated: true)
    }
}
