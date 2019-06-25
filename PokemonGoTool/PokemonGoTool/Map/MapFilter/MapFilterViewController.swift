
import UIKit

class MapFilterViewController: UIViewController, StoryboardInitialViewController {

    private let stackView = OuterVerticalStackView()
    private let arenasFilterStackView = FilterStackView()
    private let pokstopsFilterStackView = FilterStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addToView(view)
        
        let arenaFilter = LabelSwitchRow()
        let arenaOnlyEXFilter = LabelSwitchRow()
        let arenaOnlyRaidFilter = LabelSwitchRow()
        
        arenaFilter.setup("Arenas", isOn: AppSettings.showArenas) { isOn in
            AppSettings.showArenas = isOn
            arenaOnlyRaidFilter.changeVisibility(isOn)
            arenaOnlyEXFilter.changeVisibility(isOn)
        }
        
        arenaOnlyEXFilter.setup("Nur EX", isOn: AppSettings.showOnlyEXArenas, isSubRow: true) { isOn in
            AppSettings.showOnlyEXArenas = isOn
        }
        
        arenaOnlyRaidFilter.setup("Nur mit Raid", isOn: AppSettings.showOnlyArenasWithRaid, isSubRow: true) { isOn in
            AppSettings.showOnlyArenasWithRaid = isOn
        }
        
        arenasFilterStackView.setup(mainRow: arenaFilter, subRows: [arenaOnlyRaidFilter,
                                                                    arenaOnlyEXFilter])
        
        

        let pokestopFilter = LabelSwitchRow()
        let pokestopOnlyQuestFilterRow = LabelSwitchRow()
        
        pokestopFilter.setup("Pokestops", isOn: AppSettings.showPokestops) { isOn in
            pokestopOnlyQuestFilterRow.changeVisibility(isOn)
            AppSettings.showPokestops = isOn
        }
        
        pokestopOnlyQuestFilterRow.setup("Nur mit Quest", isOn: AppSettings.showOnlyPokestopsWithQuest, isSubRow: true) { isOn in
            AppSettings.showOnlyPokestopsWithQuest = isOn
        }
        
        pokstopsFilterStackView.setup(mainRow: pokestopFilter, subRows: [pokestopOnlyQuestFilterRow])

        
        stackView.addArrangedSubview(arenasFilterStackView)
        stackView.addSepartor()
        stackView.addArrangedSubview(pokstopsFilterStackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Filter")
        AppSettings.filterSettingsChanged = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showBannerIfNeeded()
    }
    
    private func showBannerIfNeeded() {
        if AppSettings.isFilterActive {
            NotificationBannerManager.shared.show(.filterActive)
        } else {
            NotificationBannerManager.shared.dismiss()
        }
    }
}

class FilterStackView: InnerVerticalStackView {
    
    var mainRow: LabelSwitchRow!
    var subRows: [LabelSwitchRow]?
    
    func setup(mainRow: LabelSwitchRow, subRows: [LabelSwitchRow]) {
        self.mainRow = mainRow
        self.subRows = subRows
        addArrangedSubview(mainRow)
        subRows.forEach {
            $0.isVisible = mainRow.isOn
            addArrangedSubview($0)
        }
    }
}

class LabelSwitchRow: UIStackView {
    private let label = Label()
    private let settingsSwitch = UISwitch()
    private var isSubRow = false
    var isOn: Bool {
        get {
            return settingsSwitch.isOn
        }
        set {
            if isSubRow {
                isVisible = newValue
            }
            settingsSwitch.isOn = newValue
        }
    }
    
    func setup(_ title: String, isOn: Bool, isSubRow: Bool = false, settingsClosure: @escaping (Bool) -> Void) {
        self.isSubRow = isSubRow
        self.isOn = isOn
        axis = .horizontal
        label.translatesAutoresizingMaskIntoConstraints = false
        settingsSwitch.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        addArrangedSubview(label)
        addArrangedSubview(settingsSwitch)
        
        settingsSwitch.addAction(for: .valueChanged) { [weak self] in
            settingsClosure(self?.settingsSwitch.isOn ?? false)
        }
    }
    
    func changeVisibility(_ visible: Bool) {
        
        let changeAlpha = {
            self.alpha = visible ? 1 : 0
        }
        
        let changeVisibility = {
            self.isVisible = visible
        }
        
        UIView.animate(withDuration: 0.125, animations: {
            visible ? changeVisibility() : changeAlpha()
        }) { _ in
            UIView.animate(withDuration: 0.125, animations: {
                visible ? changeAlpha() : changeVisibility()
            })
        }
    }
}
