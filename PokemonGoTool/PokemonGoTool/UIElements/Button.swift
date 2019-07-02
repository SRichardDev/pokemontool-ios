import UIKit

@IBDesignable
class Button: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    var isDestructive: Bool = false {
        didSet {
            if isDestructive {
                let color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                setBackgroundColor(color: color, forState: .normal)
                layer.borderColor = color.cgColor
            } else {
                let systemBlue = UIButton(type: .system).tintColor!
                setBackgroundColor(color: systemBlue, forState: .normal)
                layer.borderColor = systemBlue.cgColor
            }
        }
    }
    
    private func setup() {
        let systemBlue = UIButton(type: .system).tintColor!
        layer.borderColor = systemBlue.cgColor
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        backgroundColor = systemBlue
        
        layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 0.2
        layer.masksToBounds = false
        layer.cornerRadius = 10
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: 44)
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: forState)
        }
    }
}
