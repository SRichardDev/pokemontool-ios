
import UIKit

class RaidBossTableViewController: UIViewController, StoryboardInitialViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func update() {
        tableView.reloadSections([0], with: UITableView.RowAnimation.fade)
        tableViewHeightConstraint.constant = tableView.contentSize.height
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentRaidBosses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel.currentRaidBosses[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
}
