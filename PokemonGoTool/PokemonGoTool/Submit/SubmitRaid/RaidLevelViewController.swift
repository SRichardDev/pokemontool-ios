
import UIKit

class RaidLevelViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var slider: SnappableSlider!
    @IBOutlet var level1Label: Label!
    @IBOutlet var level2Label: Label!
    @IBOutlet var level3Label: Label!
    @IBOutlet var level4Label: Label!
    @IBOutlet var level5Label: Label!
    var currentValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        if currentValue != Int(sender.value) {
            currentValue = Int(sender.value)
            viewModel.sliderChanged(to: Int(sender.value))
        }
    }
}

@IBDesignable
class SnappableSlider: UISlider {
    
    @IBInspectable
    var interval: Int = 1
    var currentValue = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSlider()
    }
    
    private func setUpSlider() {
        addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
    }
    
    @objc func handleValueChange(sender: UISlider) {
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
        setValue(newValue, animated: true)
        
        if currentValue != Int(newValue) {
            currentValue = Int(newValue)
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.prepare()
            feedback.impactOccurred()
        }
    }
}
