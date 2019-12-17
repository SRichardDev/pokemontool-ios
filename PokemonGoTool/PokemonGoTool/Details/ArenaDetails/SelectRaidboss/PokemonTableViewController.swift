
import UIKit

struct PokemonDexEntry: Codable, Equatable {
    let dexNumber: Int
    let name: String
}

class PokemonTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoryboardInitialViewController {

    @IBOutlet var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var pokemon = [PokemonDexEntry]()
    private var filteredPokemon = [PokemonDexEntry]()
    private var selectedPokemon: PokemonDexEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Raidboss auswählen"
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Pokémon durchsuchen"
        searchController.delegate = self

        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        guard let filepath = Bundle.main.path(forResource: "pokemon-names-de", ofType: "json") else { return }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: filepath))
        let pokemonNames = try! JSONSerialization.jsonObject(with: data, options: []) as! [String]
        var counter = 1
        for pokemonName in pokemonNames {
            let entry = PokemonDexEntry(dexNumber: counter, name: pokemonName)
            self.pokemon.append(entry)
            counter += 1
        }
        tableView.reloadData()
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPokemon.count
        }
        return pokemon.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dexCell") {
            let pokemonEntry = isFiltering() ? filteredPokemon[indexPath.row] : pokemon[indexPath.row]
            
            cell.textLabel?.text = pokemonEntry.name
            cell.imageView?.image = UIImage(named: "\(pokemonEntry.dexNumber)")
            if let selectedPokemon = selectedPokemon {
                cell.accessoryType = pokemonEntry == selectedPokemon ? .checkmark : .none
            } else {
                cell.accessoryType = .none
            }

            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            selectedPokemon = isFiltering() ? filteredPokemon[indexPath.row] : pokemon[indexPath.row]
//            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            selectedPokemon = nil
        }
    }
}

extension PokemonTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredPokemon = pokemon.filter({ pokemon -> Bool in
            return pokemon.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension PokemonTableViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {[weak self] in
            self?.searchController.searchBar.becomeFirstResponder()
        }
    }
}

class PokemonCell: UITableViewCell {
    override func prepareForReuse() {
        accessoryType = .none
    }
}

