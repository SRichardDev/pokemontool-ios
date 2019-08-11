
import UIKit

class ArenaFilterViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var stackView: HideableSubRowStackView!
    private var levelFilter: [Int: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let levelFilter = UserDefaults.standard.object(forKey: "levelFilter") as? Data {
            let decodedLevelFilter = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(levelFilter) as! [Int: Bool]
            self.levelFilter = decodedLevelFilter
        }
        
        let raidFilter = LabelSwitchRow()
        let level5Row = LabelSwitchRow()
        let level4Row = LabelSwitchRow()
        let level3Row = LabelSwitchRow()
        let level2Row = LabelSwitchRow()
        let level1Row = LabelSwitchRow()

        raidFilter.setup("Raids filtern", isOn: false) { isOn in
            level5Row.changeVisibility(isOn)
            level4Row.changeVisibility(isOn)
            level3Row.changeVisibility(isOn)
            level2Row.changeVisibility(isOn)
            level1Row.changeVisibility(isOn)
        }
        level5Row.setup("⭐️⭐️⭐️⭐️⭐️", isOn: levelFilter[5] ?? false, isSubRow: true) { isOn in
            self.levelFilter[5] = isOn
        }
        level4Row.setup("⭐️⭐️⭐️⭐️", isOn: levelFilter[4] ?? false, isSubRow: true) { isOn in
            self.levelFilter[4] = isOn
        }
        level3Row.setup("⭐️⭐️⭐️", isOn: levelFilter[3] ?? false, isSubRow: true) { isOn in
            self.levelFilter[3] = isOn
        }
        level2Row.setup("⭐️⭐️", isOn: levelFilter[2] ?? false, isSubRow: true) { isOn in
            self.levelFilter[2] = isOn
        }
        level1Row.setup("⭐️", isOn: levelFilter[1] ?? false, isSubRow: true) { isOn in
            self.levelFilter[1] = isOn
        }
        
        stackView.setup(mainRow: raidFilter, subRows: [level5Row,
                                                       level4Row,
                                                       level3Row,
                                                       level2Row,
                                                       level1Row])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppSettings.filterSettingsChanged = true
        
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: levelFilter, requiringSecureCoding: false)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: "levelFilter")
        } catch let error {
            print(error)
        }
    }
}
