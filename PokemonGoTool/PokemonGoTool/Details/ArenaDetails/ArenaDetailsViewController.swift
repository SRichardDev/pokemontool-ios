
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
        stackView.addSepartor()
        
        if !viewModel.isRaidExpired {
            stackView.addArrangedViewController(viewController: restTimeViewController, to: self)
            stackView.addSepartor()
            stackView.addArrangedViewController(viewController: meetupTimeViewController, to: self)
            stackView.addArrangedViewController(viewController: meetupTimeSelectionViewController, to: self)
            stackView.addSepartor()
            stackView.addArrangedViewController(viewController: userParticipatesSwitchViewController, to: self)
            stackView.addSepartor()
            stackView.addArrangedViewController(viewController: participantsOverviewViewController, to: self)
            stackView.addSepartor()
        }
        
        stackView.addArrangedViewController(viewController: goldSwitchViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: infoViewController, to: self)
        
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
        participantsOverviewViewController.view.isHidden = viewModel.isRaidExpired
        meetupTimeViewController.view.isHidden = !viewModel.hasActiveMeetup || viewModel.isRaidExpired
        meetupTimeSelectionViewController.view.isHidden = viewModel.hasActiveMeetup || viewModel.isRaidExpired
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(viewModel.title)
    }
    
    func updateUI() {
        meetupTimeViewController.view.isHidden = !viewModel.hasActiveMeetup || viewModel.isRaidExpired
        meetupTimeSelectionViewController.view.isHidden = viewModel.hasActiveMeetup || viewModel.isRaidExpired
    }
    
    var animating = false
    func update(of type: ArenaDetailsUpdateType) {
        switch type {
        case .meetupChanged:
            participantsOverviewViewController.updateUI()
            userParticipatesSwitchViewController.updateUI()
            meetupTimeViewController.updateUI()
            updateUI()
        case .timeLeftChanged(let timeLeft):
            restTimeViewController.updateTimeLeft(timeLeft)
            restTimeViewController.view.isHidden = viewModel.isRaidExpired
        case .hatchTimeLeftChanged(let timeLeft):
            restTimeViewController.updateHatchTimeLeft(timeLeft)
        case .goldArenaChanged(let isGold):
            headerViewController.updateArenaImage(isGold: isGold)
        case .createRaidMeetup:
            let alert = UIAlertController(title: "Stimmt der Treffpunkt?",
                                          message: viewModel.selectedMeetupTime,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { action in
                self.viewModel.createRaidMeetup()
                self.updateUI()
            }))
            alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: { action in
                self.userParticipatesSwitchViewController.updateUI()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
