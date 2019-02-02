
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController, SubmitRaidDelegate {
    
    weak var coordinator: MainCoordinator?
    var firebaseConnector: FirebaseConnector!
    private let stackView = UIStackView()
    private let raidLevelViewController = RaidLevelViewController.instantiateFromStoryboard()
    private let hatchTimePickerViewController = RaidHatchTimePickerViewController.instantiateFromStoryboard()
    private let timeLeftPickerViewController = RaidTimeLeftPickerViewController.instantiateFromStoryboard()
    private let userParticipatesViewController = RaidUserParticipateSwitchViewController.instantiateFromStoryboard()
    private let meetupTimePickerViewController = RaidMeetupTimePickerViewController.instantiateFromStoryboard()
    private let switchViewController = RaidAlreadyRunningSwitchViewController.instantiateFromStoryboard()
    private let doneButton = Button()
    let viewModel = SubmitRaidViewModel()
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        let separatorView = SeparatorView.instantiateFromNib()
        let separatorView1 = SeparatorView.instantiateFromNib()

        raidLevelViewController.viewModel = viewModel
        switchViewController.viewModel = viewModel
        hatchTimePickerViewController.viewModel = viewModel
        timeLeftPickerViewController.viewModel = viewModel
        userParticipatesViewController.viewModel = viewModel
        meetupTimePickerViewController.viewModel = viewModel

        timeLeftPickerViewController.view.isHidden = true
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedViewController(viewController: raidLevelViewController, to: self)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedViewController(viewController: switchViewController, to: self)
        stackView.addArrangedViewController(viewController: hatchTimePickerViewController, to: self)
        stackView.addArrangedViewController(viewController: timeLeftPickerViewController, to: self)
        stackView.addArrangedSubview(separatorView1)
        stackView.addArrangedViewController(viewController: userParticipatesViewController, to: self)
        stackView.addArrangedViewController(viewController: meetupTimePickerViewController, to: self)
        stackView.addArrangedSubview(doneButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle()
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
            setTitle()

        case .raidAlreadyRunning:
            hatchTimePickerViewController.view.isHidden = !viewModel.showHatchTimePicker
            timeLeftPickerViewController.view.isHidden = viewModel.showHatchTimePicker
        case .userParticipates:
            changeVisibility(of: meetupTimePickerViewController, visible: viewModel.showMeetupTimePicker)
        }
    }
    
    private func setTitle() {
        navigationController?.navigationBar.topItem?.title = "Neuer Level \(viewModel.currentRaidLevel) Raid"
    }
    
    private func changeVisibility(of viewController: UIViewController, visible: Bool) {
        UIView.animate(withDuration: 0.125, animations: {
            viewController.view.alpha = visible ? 1 : 0
        }) { done in
            UIView.animate(withDuration: 0.25) {
                viewController.view.isHidden = !visible
            }
        }
    }
}
