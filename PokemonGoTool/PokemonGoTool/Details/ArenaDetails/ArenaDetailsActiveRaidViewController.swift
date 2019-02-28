
import UIKit

class ArenaDetailsActiveRaidViewController: UIViewController, StoryboardInitialViewController, RaidTimeLeftDelegate, RaidMeetupDelegate {
    
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var bossEggImageView: UIImageView!
    @IBOutlet var bossEggNameLabel: Label!
    @IBOutlet var restTimeLabel: Label!
    @IBOutlet var participantsTitleLabel: Label!
    @IBOutlet var participantsTableView: UITableView!
    @IBOutlet var participantsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var participateButton: Button!
    @IBOutlet var chatTitleLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantsTableView.delegate = self
        participantsTableView.dataSource = self
        participantsTableView.reloadData()
        restTimeLabel.text = "-- : -- : --"
        viewModel.delegate = self
        viewModel.meetupDelegate = self
        bossEggImageView.image = viewModel.image
        bossEggNameLabel.text = viewModel.arena.raid?.raidBoss?.name
    }

    func didUpdateTimeLeft(_ string: String) {
        restTimeLabel.text = string
    }
    
    func didUpdateMeetup() {
        participantsTableView.reloadData()
        participantsTableViewHeightConstraint.constant = participantsTableView.contentSize.height
    }
    
    @IBAction func participateTapped(_ sender: Any) {
        
    }
}

extension ArenaDetailsActiveRaidViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.participants?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell")!
        cell.textLabel?.text = viewModel.participants?[indexPath.row].trainerName
        return cell
    }
}
