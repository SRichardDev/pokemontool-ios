
import Foundation

struct PokemonDexEntry: Codable, Equatable {
    let dexNumber: Int
    let name: String
}

class RaidbossManager {

    static let shared = RaidbossManager()
    
    private(set) var pokemon = [PokemonDexEntry]()
    
    private init() {
//https://stackoverflow.com/questions/59400841/notificationservice-extension-returns-different-locale-than-app-target
//        let locale = Locale.current.identifier.components(separatedBy: "_").first ?? "en"
//        let filepath = Bundle.main.path(forResource: "pokemon-names-\(locale)", ofType: "json") ??
//                       Bundle.main.path(forResource: "pokemon-names-en", ofType: "json")!
        let filepath = Bundle.main.path(forResource: "pokemon-names-de", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filepath))
        let pokemonNames = try! JSONSerialization.jsonObject(with: data, options: []) as! [String]
        
        var counter = 1
        for pokemonName in pokemonNames {
            let entry = PokemonDexEntry(dexNumber: counter, name: pokemonName)
            pokemon.append(entry)
            counter += 1
        }
    }
}
