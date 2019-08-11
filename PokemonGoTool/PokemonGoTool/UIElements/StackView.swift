
import UIKit

@IBDesignable
class OuterVerticalStackView: UIStackView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        axis = .vertical
        spacing = 50
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
        
//        let backgroundView = UIView()
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.backgroundColor = .orange
//        backgroundView.layer.cornerRadius = 10
//        addSubview(backgroundView)
//        sendSubviewToBack(backgroundView)
//        NSLayoutConstraint.activate([leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 10),
//                                     rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -10),
//                                     topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
//                                     bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)])
    }
    
    func addToView(_ view: UIView) {
        view.addSubviewAndEdgeConstraints(self,
                                          edges: .all,
                                          margins: UIEdgeInsets(top: 40, left: 25, bottom: 25, right: 25),
                                          constrainToSafeAreaGuide: true)
    }
}

class InnerVerticalStackView: OuterVerticalStackView {
    
    override func setup() {
        axis = .vertical
        spacing = 15
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundView = UIView()
        backgroundView.addShadow()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        backgroundView.layer.borderWidth = 1
        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        NSLayoutConstraint.activate([leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 7),
                                     rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -7),
                                     topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 7),
                                     bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -7)])
    }
}

class HideableSubRowStackView: InnerVerticalStackView {
    
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

