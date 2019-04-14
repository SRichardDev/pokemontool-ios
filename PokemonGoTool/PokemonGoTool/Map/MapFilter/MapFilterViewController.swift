
import UIKit

class MapFilterViewController: UIViewController, StoryboardInitialViewController {

    private let stackView = OuterVerticalStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addToView(view)
        
        let arenaOnlyEXFilter = LabelSwitchRow()
        arenaOnlyEXFilter.setup("Nur EX") { isOn in
            
        }
        
        let arenaOnlyRaidFilter = LabelSwitchRow()
        arenaOnlyRaidFilter.setup("Nur mit Raid") { isOn in
            
        }
        
        let arenaFilter = LabelSwitchRow()
        arenaFilter.setup("Arenas") { isOn in
            arenaOnlyRaidFilter.changeVisibility(isOn)
            arenaOnlyEXFilter.changeVisibility(isOn)
        }
        
        let pokestopOnlyQuestFilterRow = LabelSwitchRow()
        pokestopOnlyQuestFilterRow.setup("Nur mit Quest") { isOn in
            
        }
        
        let pokestopFilter = LabelSwitchRow()
        pokestopFilter.setup("Pokestops") { isOn in
            pokestopOnlyQuestFilterRow.changeVisibility(isOn)
        }
        
        stackView.addArrangedSubview(arenaFilter)
        stackView.addArrangedSubview(arenaOnlyRaidFilter)
        stackView.addArrangedSubview(arenaOnlyEXFilter)
        stackView.addSepartor()
        stackView.addArrangedSubview(pokestopFilter)
        stackView.addArrangedSubview(pokestopOnlyQuestFilterRow)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Filter")
    }
}

class LabelSwitchRow: UIStackView {
    let label = Label()
    let settingsSwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(_ title: String, settingsClosure: @escaping (Bool) -> Void) {
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
