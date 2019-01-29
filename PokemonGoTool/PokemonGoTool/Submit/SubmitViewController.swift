
import UIKit
import MapKit

class SubmitViewController: UIViewController, StoryboardInitialViewController, SubmitMapEmbeddable {

    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var containerView: UIView!
    var mapViewController: SubmitMapViewController!
    var viewModel: SubmitViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        mapViewController = embedMap(coordinate: viewModel.coordinate)
    }

    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewModel.submitType = .pokestop
            mapViewController.addPokestopAnnotation()
        } else if sender.selectedSegmentIndex == 1 {
            viewModel.submitType = .arena(isEX: false)
            mapViewController.addArenaAnnotation()
        }
        title = viewModel.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SubmitNameViewController {
            viewModel.coordinate = mapViewController.locationOnMap
            destination.viewModel = viewModel
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
