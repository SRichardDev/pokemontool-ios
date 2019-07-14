
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController, ArenaDetailsDelegate {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = OuterVerticalStackView()
    private let headerViewController = ArenaDetailsHeaderViewController.fromStoryboard()
    private let participantsTableViewController = ArenaDetailsParticipantsTableViewController.fromStoryboard()
    private let participantsOverviewViewController = ArenaDetailsParticipantsOverviewViewController.fromStoryboard()
    private let restTimeViewController = ArenaDetailsRestTimeViewController.fromStoryboard()
    private let infoViewController = ArenaDetailsInfoViewController.fromStoryboard()
    private let meetupTimeViewController = ArenaDetailsMeetupTimeViewController.fromStoryboard()
    private let userParticipatesSwitchViewController = ArenaDetailsUserParticipatesViewController.fromStoryboard()
    private let goldSwitchViewController = ArenaDetailsGoldArenaSwitchViewController.fromStoryboard()
    private let meetupTimeSelectionViewController = RaidMeetupTimePickerViewController.fromStoryboard()
    private let raidBossCollectionViewController = RaidBossCollectionViewController.fromStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        stackView.addToView(view)
        
        headerViewController.viewModel = viewModel
        headerViewController.coordinator = coordinator
        restTimeViewController.viewModel = viewModel
        participantsTableViewController.viewModel = viewModel
        participantsOverviewViewController.viewModel = viewModel
        participantsOverviewViewController.coordinator = coordinator
        infoViewController.viewModel = viewModel
        meetupTimeViewController.viewModel = viewModel
        userParticipatesSwitchViewController.viewModel = viewModel
        goldSwitchViewController.viewModel = viewModel
        meetupTimeSelectionViewController.viewModel = viewModel
        
        stackView.addArrangedViewController(viewController: headerViewController, to: self)

        
        if !viewModel.isRaidBossSelected && viewModel.isRaidbossActive {
            stackView.addArrangedViewController(viewController: raidBossCollectionViewController, to: self)
            raidBossCollectionViewController.level = viewModel.level
            raidBossCollectionViewController.activateSelectionMode()
            raidBossCollectionViewController.selectedRaidbossCallback = { self.viewModel.updateRaidboss($0) }
        }
        
        if !viewModel.isRaidExpired {
            stackView.addArrangedViewController(viewController: restTimeViewController, to: self)
            stackView.addArrangedViewController(viewController: meetupTimeViewController, to: self)
            stackView.addArrangedViewController(viewController: meetupTimeSelectionViewController, to: self)
            stackView.addArrangedViewController(viewController: userParticipatesSwitchViewController, to: self)
            stackView.addArrangedViewController(viewController: participantsOverviewViewController, to: self)
        }
        
        stackView.addArrangedViewController(viewController: goldSwitchViewController, to: self)
        stackView.addArrangedViewController(viewController: infoViewController, to: self)
        
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
        participantsOverviewViewController.view.isHidden = viewModel.isRaidExpired
        meetupTimeViewController.view.isHidden = viewModel.isTimeSetForMeetup || viewModel.isRaidExpired
        meetupTimeSelectionViewController.view.isHidden = !viewModel.isTimeSetForMeetup || viewModel.isRaidExpired
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(viewModel.title)
    }
    
    var animating = false
    func update(of type: ArenaDetailsUpdateType) {
        switch type {
        case .meetupChanged:
            participantsOverviewViewController.updateUI()
            userParticipatesSwitchViewController.updateUI()
            meetupTimeViewController.updateUI()
        case .timeLeftChanged(let timeLeft):
            restTimeViewController.updateTimeLeft(timeLeft)
            restTimeViewController.view.isHidden = viewModel.isRaidExpired
        case .hatchTimeLeftChanged(let timeLeft):
            restTimeViewController.updateHatchTimeLeft(timeLeft)
        case .goldArenaChanged:
            headerViewController.updateUI()
        case .eggHatched:
            headerViewController.updateUI()
        case .raidbossChanged:
            headerViewController.updateUI()
            setTitle(viewModel.title)
        case .changeMeetupTime:
            changeVisibiltyOf(viewControllers: [meetupTimeViewController, meetupTimeSelectionViewController])
        }
    }
}
