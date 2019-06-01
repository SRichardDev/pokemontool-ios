
import UIKit

struct PokemonDexEntry: Codable {
    let name: String
}

class PokemonTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoryboardInitialViewController {

    @IBOutlet var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var pokemon = [PokemonDexEntry]()
    var filteredPokemon = [PokemonDexEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Raidboss auswählen"
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Pokémon durchsuchen"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["Gen 1", "Gen 2", "Gen 3", "Gen 4"]
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        guard let filepath = Bundle.main.path(forResource: "pokemon-names-de", ofType: "json") else { return }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: filepath))
        let pokemonNames = try! JSONSerialization.jsonObject(with: data, options: []) as! [String]
        
        for pokemonName in pokemonNames {
            let entry = PokemonDexEntry(name: pokemonName)
            self.pokemon.append(entry)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemon.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dexCell") {
            let pokemonEntry = pokemon[indexPath.row]
            cell.textLabel?.text = pokemonEntry.name
            cell.imageView?.image = UIImage(named: "\(indexPath.row + 1)")
            
            return cell
        }
        return UITableViewCell()
    }
}

extension PokemonTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Alle") {
        filteredPokemon = pokemon.filter({ pokemon -> Bool in
            let doesCategoryMatch = (scope == "Alle") || (pokemon.name.components(separatedBy: " ").first == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && pokemon.name.lowercased().contains(searchText.lowercased())
            }
        })
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

extension PokemonTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

