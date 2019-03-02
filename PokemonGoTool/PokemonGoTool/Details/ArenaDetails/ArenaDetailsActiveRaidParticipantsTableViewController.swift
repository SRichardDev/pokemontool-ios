
import UIKit

class ArenaDetailsActiveRaidParticipantsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RaidMeetupDelegate, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.meetupDelegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! ParticipantsTableViewCell
        let user = Array(viewModel.participants.values)[indexPath.row]
        cell.trainerNameLabel.text = user.trainerName
        cell.levelLabel.text = "\(user.level ?? 0)"
        return cell
    }
    
    func didUpdateMeetup() {
        updateUI()
    }
    
    func didUpdateUsers() {
        updateUI()
    }
    
    private func updateUI() {
        tableView.reloadData()
        heightConstraint.constant = tableView.contentSize.height

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

class ParticipantsTableViewCell: UITableViewCell {
    
    @IBOutlet var levelLabel: Label!
    @IBOutlet var teamBackgroundView: UIView!
    @IBOutlet var trainerNameLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        teamBackgroundView.layer.cornerRadius = teamBackgroundView.bounds.width / 2
    }
}
