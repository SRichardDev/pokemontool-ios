
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController, SubmitRaidDelegate {
    
    weak var coordinator: MainCoordinator?
    var firebaseConnector: FirebaseConnector!
    private let stackView = StackView()
    private let imageView = UIImageView()
    private let raidLevelViewController = RaidLevelViewController.instantiateFromStoryboard()
    private let raidBossCollectionViewController = RaidBossCollectionViewController.instantiateFromStoryboard()
    private let hatchTimePickerViewController = RaidHatchTimePickerViewController.instantiateFromStoryboard()
    private let timeLeftPickerViewController = RaidTimeLeftPickerViewController.instantiateFromStoryboard()
    private let userParticipatesViewController = RaidUserParticipateSwitchViewController.instantiateFromStoryboard()
    private let meetupTimePickerViewController = RaidMeetupTimePickerViewController.instantiateFromStoryboard()
    private let raidAlreadyRunningSwitchViewController = RaidAlreadyRunningSwitchViewController.instantiateFromStoryboard()
    private let doneButton = Button()
    var viewModel: SubmitRaidViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.addSubviewAndEdgeConstraints(stackView,
                                          edges: .all,
                                          margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                          constrainToSafeAreaGuide: false)
        
        doneButton.setTitle("Raid melden", for: .normal)
        doneButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        let image = UIImage(named: viewModel.imageName)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        raidLevelViewController.viewModel = viewModel
        raidBossCollectionViewController.viewModel = viewModel
        raidAlreadyRunningSwitchViewController.viewModel = viewModel
        hatchTimePickerViewController.viewModel = viewModel
        timeLeftPickerViewController.viewModel = viewModel
        userParticipatesViewController.viewModel = viewModel
        meetupTimePickerViewController.viewModel = viewModel

        timeLeftPickerViewController.view.isVisible = viewModel.isRaidAlreadyRunning
        meetupTimePickerViewController.view.isVisible = viewModel.isUserParticipating
        
        let arenaNameLabel = Label()
        arenaNameLabel.style = 3
        arenaNameLabel.text = viewModel.arena.name
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(arenaNameLabel)
        stackView.addArrangedViewController(viewController: raidLevelViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: raidAlreadyRunningSwitchViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: raidBossCollectionViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: hatchTimePickerViewController, to: self)
        stackView.addArrangedViewController(viewController: timeLeftPickerViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: userParticipatesViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: meetupTimePickerViewController, to: self)
        stackView.addArrangedSubview(doneButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Neuer Level \(viewModel.selectedRaidLevel) Raid")
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRaidboss))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = addItem
    }
    
    @objc
    func submitTapped() {
        viewModel.submitRaid()
        dismiss(animated: true)
    }
    
    func update(of type: SubmitRaidUpdateType) {
        switch type {
        case .raidLevelChanged:
            UIView.transition(with: imageView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.imageView.image = UIImage(named: self.viewModel.imageName)!
                self.setTitle("Neuer Level \(self.viewModel.selectedRaidLevel) Raid")
            })

        case .raidAlreadyRunning:
            changeVisibiltyOf(viewControllers: [hatchTimePickerViewController,
                                                timeLeftPickerViewController])
            raidBossCollectionViewController.toggleScrolling()
        case .userParticipates:
            changeVisibility(of: meetupTimePickerViewController, visible: viewModel.isUserParticipating, hideAnimated: true)
        case .currentRaidbossesChanged:
            raidBossCollectionViewController.updateRaidBosses()
        }
    }
    
    @objc
    func addRaidboss() {
        let alert = UIAlertController(title: "Neuer Raidboss", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Senden", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let textField1 = alert.textFields![1] as UITextField
            let textField2 = alert.textFields![2] as UITextField
            
            let raidboss = ["name" : textField.text!,
                         "level" : textField1.text!,
                         "imageName" : textField2.text!]
            self.firebaseConnector.addRaidBoss(raidboss)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Level"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Image Name"
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated:true)
    }
}


