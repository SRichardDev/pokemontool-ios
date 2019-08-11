
import UIKit

class MapFilterViewController: UIViewController, StoryboardInitialViewController {

    private let stackView = OuterVerticalStackView()
    private let arenaFilterViewController = ArenaFilterViewController.fromStoryboard()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addToView(view)
        
        stackView.addArrangedViewController(arenaFilterViewController, to: self)
        
        
//        let arenaFilter = LabelSwitchRow()
//        let arenaOnlyEXFilter = LabelSwitchRow()
//        let arenaOnlyRaidFilter = LabelSwitchRow()
//
//        arenaFilter.setup("Arenas", isOn: AppSettings.showArenas) { isOn in
//            AppSettings.showArenas = isOn
//            arenaOnlyRaidFilter.changeVisibility(isOn)
//            arenaOnlyEXFilter.changeVisibility(isOn)
//        }
//
//        arenaOnlyEXFilter.setup("Nur EX", isOn: AppSettings.showOnlyEXArenas, isSubRow: true) { isOn in
//            AppSettings.showOnlyEXArenas = isOn
//        }
//
//        arenaOnlyRaidFilter.setup("Nur mit Raid", isOn: AppSettings.showOnlyArenasWithRaid, isSubRow: true) { isOn in
//            AppSettings.showOnlyArenasWithRaid = isOn
//        }
//
//        arenasFilterStackView.setup(mainRow: arenaFilter, subRows: [arenaOnlyRaidFilter,
//                                                                    arenaOnlyEXFilter])
//
//
//
//        let pokestopFilter = LabelSwitchRow()
//        let pokestopOnlyQuestFilterRow = LabelSwitchRow()
//
//        pokestopFilter.setup("Pokestops", isOn: AppSettings.showPokestops) { isOn in
//            pokestopOnlyQuestFilterRow.changeVisibility(isOn)
//            AppSettings.showPokestops = isOn
//        }
//
//        pokestopOnlyQuestFilterRow.setup("Nur mit Quest", isOn: AppSettings.showOnlyPokestopsWithQuest, isSubRow: true) { isOn in
//            AppSettings.showOnlyPokestopsWithQuest = isOn
//        }
//
//        pokstopsFilterStackView.setup(mainRow: pokestopFilter, subRows: [pokestopOnlyQuestFilterRow])
//
//
//        stackView.addArrangedSubview(arenasFilterStackView)
//        stackView.addArrangedSubview(pokstopsFilterStackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Filter")
        AppSettings.filterSettingsChanged = true
    }
}

