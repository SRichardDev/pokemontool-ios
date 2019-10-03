
import UIKit

enum LabelStyle: Int {
    case normal
    case subtitle
}

@IBDesignable
class Label: UILabel {
    
    @IBInspectable var style: Int = 0 {
        didSet {
            if style == 0 {
                textColor = .label
                font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            } else if style == 1 {
                textColor = .lightGray
                font = UIFont.systemFont(ofSize: 12, weight: .regular)
            } else if style == 2 {
                textColor = .label
                font = UIFont.systemFont(ofSize: 25, weight: .semibold)
            } else if style == 3 {
                textColor = .label
                font = UIFont.systemFont(ofSize: 25, weight: .semibold)
                textAlignment = .center
            } else if style == 4 {
                textColor = .label
                font = UIFont.systemFont(ofSize: 15, weight: .regular)
            } else if style == 5 {
                textColor = .gray
                font = UIFont.systemFont(ofSize: 12, weight: .regular)
            } else if style == 6 {
                textColor = .label
                font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            } else if style == 7 {
                textColor = .label
                font = UIFont.boldSystemFont(ofSize: 34)
            } else if style == 8 {
                textColor = .red
                font = UIFont.systemFont(ofSize: 12, weight: .regular)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UILabel{
    
    func animation(typing value: String, duration: Double){
        let characters = value.map { $0 }
        var index = 0
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] timer in
            if index < value.count {
                let char = characters[index]
                self?.text! += "\(char)"
                index += 1
            } else {
                timer.invalidate()
            }
        })
    }
    
    
    func textWithAnimation(text: String, duration: CFTimeInterval){
        fadeTransition(duration)
        self.text = text
    }
    
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
