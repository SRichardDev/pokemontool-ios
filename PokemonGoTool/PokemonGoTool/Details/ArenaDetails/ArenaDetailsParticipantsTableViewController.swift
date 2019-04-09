
import UIKit

class ArenaDetailsParticipantsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "Teilnehmer"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! ParticipantsTableViewCell
        let user = Array(viewModel.participants.values)[indexPath.row]
        cell.trainerNameLabel.text = user.trainerName
        cell.levelLabel.text = "\(user.level ?? 0)"
        cell.teamBackgroundView.backgroundColor = user.team?.color
        return cell
    }
    
    func updateUI() {
        tableView.reloadSections([0], with: .automatic)
    }
}

class ParticipantsTableViewCell: UITableViewCell {
    
    @IBOutlet var levelLabel: Label!
    @IBOutlet var teamBackgroundView: UIView!
    @IBOutlet var trainerNameLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        levelLabel.textColor = .white
        teamBackgroundView.layer.cornerRadius = teamBackgroundView.bounds.width / 2
    }
}
