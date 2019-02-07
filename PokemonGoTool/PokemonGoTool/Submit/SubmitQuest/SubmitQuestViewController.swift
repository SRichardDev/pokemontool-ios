
import UIKit

class SubmitQuestViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var firebaseConnector: FirebaseConnector!
    var pokestop: Pokestop!
    var filteredQuests = [QuestDefinition]()

    @IBOutlet var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

    var quests: [QuestDefinition]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Neue Quest"
        
        tableView.delegate = self
        tableView.dataSource = self
        firebaseConnector.loadQuests { quests in
            self.quests = quests
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Quests durchsuchen"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["Alle", "Fange", "Lande", "Gewinne"]
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension SubmitQuestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredQuests.count
        }
        return quests?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questCell") as! SubmitQuestCell
        
        var quest: QuestDefinition?
        if isFiltering() {
            quest = filteredQuests[indexPath.row]
        } else {
            quest = quests?[indexPath.row]
        }
        
        cell.titleLabel.text = quest?.quest
        cell.subtitleLabel.text = quest?.reward
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SubmitQuestCell
        guard let questName = cell.titleLabel.text else { fatalError() }
        guard let reward = cell.subtitleLabel.text else { fatalError() }
        guard let trainerName = firebaseConnector.user?.trainerName else { fatalError() }
        let quest = Quest(name: questName, reward: reward, submitter: trainerName)
        firebaseConnector.saveQuest(quest: quest, for: pokestop)
        dismiss(animated: true, completion: nil)
    }
}

class SubmitQuestCell: UITableViewCell {
    
    @IBOutlet var rewardImageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var subtitleLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension SubmitQuestViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Alle") {
        guard let quests = quests else { return }
        filteredQuests = (quests.filter({( quest : QuestDefinition) -> Bool in
            let doesCategoryMatch = (scope == "Alle") || (quest.quest.components(separatedBy: " ").first == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && quest.quest.lowercased().contains(searchText.lowercased())
            }
        }))
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension SubmitQuestViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
