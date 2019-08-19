
import UIKit

class ArenaFilterViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var stackView: OuterVerticalStackView!
    private let userDefaults = UserDefaults.standard
    private lazy var isArenaFilterOn = userDefaults.bool(forKey: arenaFilterKey)
    private var levelFilters: [Int: Bool] = [:]
    private let arenaFilterKey = "arenaFilter"
    private let levelFilterKey = "levelFilter"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let levelFilter = userDefaults.object(forKey: levelFilterKey) as? Data {
            let decodedLevelFilter = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(levelFilter) as! [Int: Bool]
            self.levelFilters = decodedLevelFilter
        }
        
        let raidFilterIsOn = levelFilters.values.reduce(false) { $0 || $1 }
        
        let raidFilter = LabelSwitchRow()
        let level5Row = LabelSwitchRow()
        let level4Row = LabelSwitchRow()
        let level3Row = LabelSwitchRow()
        let level2Row = LabelSwitchRow()
        let level1Row = LabelSwitchRow()

        raidFilter.setup("Raids filtern", isOn: raidFilterIsOn) { isOn in
            level5Row.changeVisibility(isOn)
            level4Row.changeVisibility(isOn)
            level3Row.changeVisibility(isOn)
            level2Row.changeVisibility(isOn)
            level1Row.changeVisibility(isOn)
            
            if isOn == false {
                level5Row.isOn = false
                level4Row.isOn = false
                level3Row.isOn = false
                level2Row.isOn = false
                level1Row.isOn = false
                self.levelFilters[5] = false
                self.levelFilters[4] = false
                self.levelFilters[3] = false
                self.levelFilters[2] = false
                self.levelFilters[1] = false
            }
        }
        level5Row.setup("⭐️⭐️⭐️⭐️⭐️", isOn: levelFilters[5] ?? false, isSubRow: true) { isOn in
            self.levelFilters[5] = isOn
        }
        level4Row.setup("⭐️⭐️⭐️⭐️", isOn: levelFilters[4] ?? false, isSubRow: true) { isOn in
            self.levelFilters[4] = isOn
        }
        level3Row.setup("⭐️⭐️⭐️", isOn: levelFilters[3] ?? false, isSubRow: true) { isOn in
            self.levelFilters[3] = isOn
        }
        level2Row.setup("⭐️⭐️", isOn: levelFilters[2] ?? false, isSubRow: true) { isOn in
            self.levelFilters[2] = isOn
        }
        level1Row.setup("⭐️", isOn: levelFilters[1] ?? false, isSubRow: true) { isOn in
            self.levelFilters[1] = isOn
        }
        
        let levelFilterStackView = HideableSubRowStackView()
        
        levelFilterStackView.setup(mainRow: raidFilter, subRows: [level5Row,
                                                                  level4Row,
                                                                  level3Row,
                                                                  level2Row,
                                                                  level1Row])
        
        let arenaFilterStackView = HideableSubRowStackView()
        let arenaFilter = LabelSwitchRow()
        arenaFilter.setup("Arenen", isOn: isArenaFilterOn) { isOn in
            self.userDefaults.set(isOn, forKey: self.arenaFilterKey)
            levelFilterStackView.changeVisibilityAnimated(visible: isOn)
        }
        arenaFilterStackView.setup(mainRow: arenaFilter)
        
        stackView.addArrangedSubview(arenaFilterStackView)
        stackView.addArrangedSubview(levelFilterStackView)
        levelFilterStackView.isVisible = isArenaFilterOn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppSettings.filterSettingsChanged = true
        
        
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: levelFilters, requiringSecureCoding: false)
            userDefaults.set(encodedData, forKey: levelFilterKey)
        } catch let error {
            print(error)
        }
    }
}
