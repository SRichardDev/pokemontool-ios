
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController, SubmitRaidDelegate {
    
    weak var coordinator: MainCoordinator?
    var firebaseConnector: FirebaseConnector!
    private let stackView = UIStackView()
    private let raidLevelViewController = RaidLevelViewController.instantiateFromStoryboard()
    private let pickerViewController = RaidPickerViewController.instantiateFromStoryboard()
    private let switchViewController = RaidLabelSwitchViewController.instantiateFromStoryboard()
    private let doneButton = Button()
    let viewModel = SubmitRaidViewModel()
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Neuer Raid"
        viewModel.delegate = self
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.distribution = .equalSpacing
        view.addSubviewAndEdgeConstraints(stackView, edges: .all, margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), constrainToSafeAreaGuide: false)
        
        doneButton.setTitle("Raid melden", for: .normal)
        doneButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        let image = UIImage(named: viewModel.imageName)!
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        raidLevelViewController.viewModel = viewModel
        switchViewController.viewModel = viewModel
        pickerViewController.viewModel = viewModel

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedViewController(viewController: raidLevelViewController, to: self)
        stackView.addArrangedViewController(viewController: switchViewController, to: self)
        stackView.addArrangedViewController(viewController: pickerViewController, to: self)
        stackView.addArrangedSubview(doneButton)
    }
    
    @objc
    func submitTapped() {
        dismiss(animated: true)
    }
    
    func update(of type: UpdateType) {
        switch type {
        case .raidLevelChanged:
            UIView.transition(with: imageView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.imageView.image = UIImage(named: self.viewModel.imageName)!
            })

        case .switchChanged:
            UIView.animate(withDuration: 0.125, animations: {
                self.pickerViewController.view.alpha = self.viewModel.showTimePicker ? 1 : 0
            }) { done in
                UIView.animate(withDuration: 0.25) {
                    self.pickerViewController.view.isHidden = !self.viewModel.showTimePicker
                }
            }
        }
    }
}
