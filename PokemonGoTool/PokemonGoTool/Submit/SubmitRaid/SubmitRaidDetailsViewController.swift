
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController, SubmitRaidDelegate {
    
    weak var coordinator: MainCoordinator?
    var firebaseConnector: FirebaseConnector!
    private let stackView = OuterVerticalStackView()

    private let headerViewController = SubmitRaidHeaderViewController.fromStoryboard()
    private let raidLevelViewController = RaidLevelViewController.fromStoryboard()
    private let raidBossCollectionViewController = RaidBossCollectionViewController.fromStoryboard()
    private let hatchTimePickerViewController = RaidHatchTimePickerViewController.fromStoryboard()
    private let timeLeftPickerViewController = RaidTimeLeftPickerViewController.fromStoryboard()
    private let userParticipatesViewController = RaidUserParticipateSwitchViewController.fromStoryboard()
    private let meetupTimePickerViewController = RaidMeetupTimePickerViewController.fromStoryboard()
    private let raidAlreadyRunningSwitchViewController = RaidAlreadyRunningSwitchViewController.fromStoryboard()
    private let doneButton = Button()
    var viewModel: SubmitRaidViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        stackView.addToView(view)
                
        doneButton.setTitle("Raid melden", for: .normal)
        doneButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        headerViewController.viewModel = viewModel
        raidLevelViewController.viewModel = viewModel
        raidAlreadyRunningSwitchViewController.viewModel = viewModel
        hatchTimePickerViewController.viewModel = viewModel
        timeLeftPickerViewController.viewModel = viewModel
        userParticipatesViewController.viewModel = viewModel
        meetupTimePickerViewController.viewModel = viewModel
        raidBossCollectionViewController.selectedRaidbossCallback = { self.viewModel.selectedRaidBoss = $0 }

        timeLeftPickerViewController.view.isVisible = viewModel.isRaidAlreadyRunning
        meetupTimePickerViewController.view.isVisible = viewModel.isUserParticipating
        
        stackView.addArrangedViewController(viewController: headerViewController, to: self)
        stackView.addArrangedViewController(viewController: raidLevelViewController, to: self)
        stackView.addArrangedViewController(viewController: raidAlreadyRunningSwitchViewController, to: self)
        stackView.addArrangedViewController(viewController: raidBossCollectionViewController, to: self)
        stackView.addArrangedViewController(viewController: hatchTimePickerViewController, to: self)
        stackView.addArrangedViewController(viewController: timeLeftPickerViewController, to: self)
        stackView.addArrangedViewController(viewController: userParticipatesViewController, to: self)
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
            setTitle("Neuer Level \(self.viewModel.selectedRaidLevel) Raid")
            headerViewController.updateUI()
            raidBossCollectionViewController.level = viewModel.selectedRaidLevel
        case .raidAlreadyRunning:
            changeVisibiltyOf(viewControllers: [hatchTimePickerViewController,
                                                timeLeftPickerViewController])
            if viewModel.isRaidAlreadyRunning {
                raidBossCollectionViewController.activateSelectionMode()
            } else {
                raidBossCollectionViewController.activateOverViewMode()
            }
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


