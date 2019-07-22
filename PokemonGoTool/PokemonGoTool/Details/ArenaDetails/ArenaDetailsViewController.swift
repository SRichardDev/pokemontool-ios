
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController, ArenaDetailsDelegate {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    
    private let stackView = OuterVerticalStackView()
    private let headerViewController = HeaderViewController.fromStoryboard()
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
        
        stackView.addArrangedViewController(headerViewController, to: self)
        stackView.addArrangedViewController(raidBossCollectionViewController, to: self)
        stackView.addArrangedViewController(restTimeViewController, to: self)
        stackView.addArrangedViewController(meetupTimeViewController, to: self)
        stackView.addArrangedViewController(meetupTimeSelectionViewController, to: self)
        stackView.addArrangedViewController(userParticipatesSwitchViewController, to: self)
        stackView.addArrangedViewController(participantsOverviewViewController, to: self)
        let mapViewController = SubmitMapViewController.setup(with: viewModel.coordinate, isPokestop: false)
        stackView.addArrangedViewController(mapViewController, to: self)
        stackView.addArrangedViewController(goldSwitchViewController, to: self)
        stackView.addArrangedViewController(infoViewController, to: self)

        raidBossCollectionViewController.view.isHidden = viewModel.isRaidExpired || viewModel.isRaidBossSelected || !viewModel.isRaidbossActive
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
        meetupTimeViewController.view.isHidden = viewModel.isRaidExpired
        meetupTimeSelectionViewController.view.isHidden = viewModel.isRaidExpired
        userParticipatesSwitchViewController.view.isHidden = viewModel.isRaidExpired
        participantsOverviewViewController.view.isHidden = viewModel.isRaidExpired
        
        raidBossCollectionViewController.level = viewModel.level
        raidBossCollectionViewController.activateSelectionMode()
        raidBossCollectionViewController.selectedRaidbossCallback = { self.viewModel.updateRaidboss($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewModel.isRaidExpired {
            let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
            navigationController?.topViewController?.navigationItem.rightBarButtonItem = shareBarButtonItem
        }
        setTitle(viewModel.title)
    }
    
    @objc
    func didTapShare() {
        let items = [viewModel.formattedRaidTextForSharing()]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    var animating = false
    func update(of type: ArenaDetailsUpdateType) {
        switch type {
        case .meetupInit:
            meetupTimeViewController.view.isVisible = viewModel.isTimeSetForMeetup || viewModel.isRaidExpired
            meetupTimeSelectionViewController.view.isHidden = viewModel.isTimeSetForMeetup || viewModel.isRaidExpired
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
        case .raidExpired:
            headerViewController.updateUI()
            hideViewControllers([raidBossCollectionViewController,
                                 restTimeViewController,
                                 meetupTimeViewController,
                                 meetupTimeSelectionViewController,
                                 userParticipatesSwitchViewController,
                                 participantsOverviewViewController])
        }
    }
}
