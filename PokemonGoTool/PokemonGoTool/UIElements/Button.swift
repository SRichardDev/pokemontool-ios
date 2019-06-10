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
        layer.cornerRadius = 10
        layer.borderColor = systemBlue.cgColor
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setBackgroundColor(color: systemBlue, forState: .normal)
        setBackgroundColor(color: systemBlue.withAlphaComponent(0.8), forState: .highlighted)
        setBackgroundColor(color: .lightGray, forState: .disabled)
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
