
import UIKit

protocol HeaderProvidable {
    var headerTitle: String { get }
    var headerImage: UIImage { get }
}

class HeaderViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: HeaderProvidable!
    weak var coordinator: MainCoordinator?
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = viewModel.headerTitle
        imageView.image = viewModel.headerImage
    }
    
    func updateUI() {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.imageView.image = self.viewModel.headerImage
        })
    }
}
