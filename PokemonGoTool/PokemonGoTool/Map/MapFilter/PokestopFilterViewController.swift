
import UIKit

class PokestopFilterViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var stackView: OuterVerticalStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pokestopFilterStackView = InnerVerticalStackView()
        let pokestopSubFilter = StackView()

        let pokestopFilter = LabelSwitchRow()
        pokestopFilter.setup("Pokéstop", isOn: AppSettings.showPokestops) { isOn in
            AppSettings.showPokestops = isOn
            pokestopSubFilter.changeVisibilityAnimated(visible: isOn)
        }
        
        let incidentRow = LabelSwitchRow()
        let questRow = LabelSwitchRow()
        pokestopSubFilter.addArrangedSubview(incidentRow)
        pokestopSubFilter.addArrangedSubview(questRow)
        
        incidentRow.setup("Team Rocket", isOn: AppSettings.isIncidentFilterActive) { isOn in
            AppSettings.isIncidentFilterActive = isOn
        }
        
        questRow.setup("Quests", isOn: AppSettings.isQuestFilterActive) { isOn in
            AppSettings.isQuestFilterActive = isOn
        }
        
        pokestopFilterStackView.addArrangedSubview(pokestopFilter)
        pokestopFilterStackView.addArrangedSubview(pokestopSubFilter)

        stackView.addArrangedSubview(pokestopFilterStackView)
        pokestopSubFilter.isVisible = AppSettings.showPokestops
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppSettings.filterSettingsChanged = true
    }
}
