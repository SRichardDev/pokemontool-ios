
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
        let publicUserData = Array(viewModel.participants.values)[indexPath.row]
        cell.userData = publicUserData
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
    @IBOutlet var copyFriendCodeButton: UIButton!
    
    var userData: PublicUserData? {
        didSet {
            trainerNameLabel.text = userData?.trainerName
            levelLabel.text = "\(userData?.level ?? 0)"
            teamBackgroundView.backgroundColor = userData?.team?.color
            copyFriendCodeButton.isVisible = userData?.trainerCode != "" && userData?.trainerCode != nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        levelLabel.textColor = .white
        teamBackgroundView.layer.cornerRadius = teamBackgroundView.bounds.width / 2
    }
    
    @IBAction func didTapAddFriend(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = userData?.trainerCode
        NotificationBannerManager.shared.show(.addFriend)
    }
}
