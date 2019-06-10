
import UIKit

class SubmitRaidHeaderViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: SubmitRaidViewModel!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: viewModel.imageName)
        titleLabel.text = viewModel.arena.name
    }
    
    func updateUI() {
        UIView.transition(with: imageView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.imageView.image = UIImage(named: self.viewModel.imageName)!
        })
    }
}
