
import UIKit

class RaidLevelViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var buttons: [LevelSelectionButton]!
    
    override func viewDidLoad() {
        changeButtonSelection()
    }
    
    @IBAction func levelButtonsTapped(_ sender: UIButton) {
        viewModel.raidLevelChanged(to: sender.tag)
        changeButtonSelection()
    }
    
    private func changeButtonSelection() {
        buttons.forEach {
            $0.isSelected = false
        }
        let activeButton = buttons[viewModel.selectedRaidLevel - 1]
        activeButton.isSelected = true
    }
}

class LevelSelectionButton: UIButton {
    
    weak var leftShapeLayer: CAShapeLayer?
    weak var rightShapeLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var isSelected: Bool {
        didSet {
            leftShapeLayer?.removeFromSuperlayer()
            rightShapeLayer?.removeFromSuperlayer()

            if isSelected {
                let leftPath = UIBezierPath()
                leftPath.move(to: CGPoint(x: bounds.width/2, y: bounds.height * 0.9))
                leftPath.addLine(to: CGPoint(x: bounds.width * 0.8, y: bounds.height * 0.9))
                
                let rightPath = UIBezierPath()
                rightPath.move(to: CGPoint(x: bounds.width/2, y: bounds.height * 0.9))
                rightPath.addLine(to: CGPoint(x: bounds.width * 0.2, y: bounds.height * 0.9))
                
                let leftShapeLayer = CAShapeLayer()
                leftShapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                leftShapeLayer.strokeColor = UIColor.green.cgColor
                leftShapeLayer.lineWidth = 2
                leftShapeLayer.path = leftPath.cgPath
                
                let rightShapeLayer = CAShapeLayer()
                rightShapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                rightShapeLayer.strokeColor = UIColor.green.cgColor
                rightShapeLayer.lineWidth = 2
                rightShapeLayer.path = rightPath.cgPath

                layer.addSublayer(leftShapeLayer)
                let leftAnimation = CABasicAnimation(keyPath: "strokeEnd")
                leftAnimation.fromValue = 0
                leftAnimation.duration = 0.5
                
                layer.addSublayer(rightShapeLayer)
                let rightAnimation = CABasicAnimation(keyPath: "strokeEnd")
                rightAnimation.fromValue = 0
                rightAnimation.duration = 0.5

                leftShapeLayer.add(leftAnimation, forKey: "leftShapeLayer")
                rightShapeLayer.add(rightAnimation, forKey: "rightShapeLayer")
                self.leftShapeLayer = leftShapeLayer
                self.rightShapeLayer = rightShapeLayer
            }
        }
    }
}
