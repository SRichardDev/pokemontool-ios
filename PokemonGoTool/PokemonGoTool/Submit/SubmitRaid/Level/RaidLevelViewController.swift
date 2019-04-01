
import UIKit

class RaidLevelViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var buttons: [LevelSelectionButton]!
    @IBOutlet var buttonBackgroundViews: [LevelSelectionButtonView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeButtonSelection()
    }
    
    @IBAction func levelButtonsTapped(_ sender: UIButton) {
        guard sender.tag != viewModel.selectedRaidLevel else { return }
        viewModel.raidLevelChanged(to: sender.tag)
        changeButtonSelection()
    }
    
    private func changeButtonSelection() {
        buttons.forEach { $0.isSelected = false }
        buttonBackgroundViews.forEach { $0.show(false) }
        let index = viewModel.selectedRaidLevel - 1
        let activeButton = buttons[index]
        let activeButtonBackgroundView = buttonBackgroundViews[index]
        activeButtonBackgroundView.show(true)
        activeButton.isSelected = true
    }
}

class LevelSelectionButtonView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.orange.cgColor
        layer.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false
        transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 3
    }
    
    func show(_ isShowing: Bool) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
                        self.transform = isShowing ? .identity : CGAffineTransform(scaleX: 0, y: 0)
        })
    }
}

class LevelSelectionButton: UIButton {

}
