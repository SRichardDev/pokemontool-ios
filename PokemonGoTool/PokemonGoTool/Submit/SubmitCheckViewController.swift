
import UIKit

class SubmitCheckViewController: UIViewController, SubmitMapEmbeddable {
    
    var viewModel: SubmitViewModel!
    var mapViewController: SubmitMapViewController!
    @IBOutlet var containerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = viewModel.submitName
        mapViewController = embedMap(coordinate: viewModel.coordinate)
        
        if viewModel.isPokestop {
            mapViewController.addPokestopAnnotation()
        } else {
            mapViewController.addArenaAnnotation()
        }
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        viewModel.submit()
        dismiss(animated: true)
    }
}
