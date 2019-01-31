
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    let stackView = UIStackView()
    let raidLevelViewController = RaidLevelViewController.instantiateFromStoryboard()
    let pickerViewController = RaidPickerViewController.instantiateFromStoryboard()
    let switchViewController = RaidLabelSwitchViewController.instantiateFromStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Neuer Raid"
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        view.addSubviewAndEdgeConstraints(stackView, edges: .all, margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), constrainToSafeAreaGuide: false)
        
        addChild(raidLevelViewController)
        addChild(pickerViewController)
        addChild(switchViewController)
        stackView.addArrangedSubview(raidLevelViewController.view)
        stackView.addArrangedSubview(pickerViewController.view)
        stackView.addArrangedSubview(switchViewController.view)
        raidLevelViewController.didMove(toParent: self)
        pickerViewController.didMove(toParent: self)
        switchViewController.didMove(toParent: self)
    }
}
