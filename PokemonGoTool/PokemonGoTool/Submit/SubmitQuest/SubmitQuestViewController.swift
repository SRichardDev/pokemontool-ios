
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
        quests = firebaseConnector.quests
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Quests durchsuchen"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["Alle", "Fange", "Lande", "Gewinne"]
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuest))
        navigationItem.rightBarButtonItem = addItem
    }
    
    @objc
    func addQuest() {
        let alert = UIAlertController(title: "Neue Quest", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Senden", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let textField1 = alert.textFields![1] as UITextField
            let textField2 = alert.textFields![2] as UITextField
            
            let quest = ["quest" : textField.text!,
                         "reward" : textField1.text!,
                         "imageName" : textField2.text!]
            self.firebaseConnector.addQuest(quest)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Quest"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Reward"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Image Name"
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated:true)
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
        
        var questDefinition: QuestDefinition?
        if isFiltering() {
            questDefinition = filteredQuests[indexPath.row]
        } else {
            questDefinition = quests?[indexPath.row]
        }
        
        guard let quest = questDefinition else { return cell }
        cell.titleLabel.text = quest.quest
        cell.subtitleLabel.text = quest.reward
        cell.rewardImageView.image = ImageManager.image(named: quest.imageName)
        cell.quest = quest
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SubmitQuestCell
        guard let userId = firebaseConnector.user?.id else { NotificationBannerManager.shared.show(.unregisteredUser); return}
        guard let questDefinition = cell.quest else { fatalError() }
        
        let quest = Quest(definitionId: questDefinition.id ?? "??",
                          submitter: userId)
        
        firebaseConnector.saveQuest(quest: quest, for: pokestop)
        NotificationBannerManager.shared.show(.questSubmitted)
        searchController.dismiss(animated: true)
        dismiss(animated: true)
    }
}

class SubmitQuestCell: UITableViewCell {
    
    @IBOutlet var rewardImageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var subtitleLabel: Label!
    
    var quest: QuestDefinition!
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
