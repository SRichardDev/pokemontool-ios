
import UIKit
import ScrollingContentViewController

class SubmitRaidDetailsViewController: ScrollingContentViewController, StoryboardInitialViewController, SubmitRaidDelegate {
    
    var viewModel: SubmitRaidViewModel!
    private let stackView = OuterVerticalStackView()
    private let headerViewController = SubmitRaidHeaderViewController.fromStoryboard()
    private let raidLevelViewController = RaidLevelViewController.fromStoryboard()
    private let raidBossViewController = RaidBossViewController.fromStoryboard()
    private let hatchTimePickerViewController = RaidHatchTimePickerViewController.fromStoryboard()
    private let timeLeftPickerViewController = RaidTimeLeftPickerViewController.fromStoryboard()
    private let userParticipatesViewController = RaidUserParticipateSwitchViewController.fromStoryboard()
    private let meetupTimePickerViewController = RaidMeetupTimePickerViewController.fromStoryboard()
    private let raidAlreadyRunningSwitchViewController = RaidAlreadyRunningSwitchViewController.fromStoryboard()
    private let submitRaidViewController = SubmitRaidViewController.fromStoryboard()
    private let doneButton = Button()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView = UIView()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        stackView.addToView(contentView)
        viewModel.delegate = self
        setupUI()
    }
    
    private func setupUI() {
        title = viewModel.title
        headerViewController.viewModel = viewModel
        raidLevelViewController.viewModel = viewModel
        raidAlreadyRunningSwitchViewController.viewModel = viewModel
        hatchTimePickerViewController.viewModel = viewModel
        timeLeftPickerViewController.viewModel = viewModel
        userParticipatesViewController.viewModel = viewModel
        meetupTimePickerViewController.viewModel = viewModel
        submitRaidViewController.viewModel = viewModel
        raidBossViewController.viewModel = viewModel
        
        timeLeftPickerViewController.view.isVisible = viewModel.isRaidAlreadyRunning
        meetupTimePickerViewController.view.isVisible = viewModel.isUserParticipating
        
        stackView.addArrangedViewController(headerViewController, to: self)
        stackView.addArrangedViewController(raidLevelViewController, to: self)
        stackView.addArrangedViewController(raidAlreadyRunningSwitchViewController, to: self)
        stackView.addArrangedViewController(raidBossViewController, to: self)
        stackView.addArrangedViewController(hatchTimePickerViewController, to: self)
        stackView.addArrangedViewController(timeLeftPickerViewController, to: self)
        stackView.addArrangedViewController(userParticipatesViewController, to: self)
        stackView.addArrangedViewController(meetupTimePickerViewController, to: self)
        stackView.addArrangedViewController(submitRaidViewController, to: self)
    }
    
    func update(of type: SubmitRaidUpdateType) {
        switch type {
        case .raidLevelChanged:
            title = viewModel.title
            headerViewController.updateUI()
        case .raidAlreadyRunning:
            changeVisibiltyOf(viewControllers: [hatchTimePickerViewController,
                                                timeLeftPickerViewController])
        case .userParticipates:
            changeVisibility(of: meetupTimePickerViewController, visible: viewModel.isUserParticipating, hideAnimated: true)
        case .raidbossChanged:
            raidBossViewController.updateUI()
        case .raidSubmitted:
            dismiss(animated: true)
        }
    }
}
