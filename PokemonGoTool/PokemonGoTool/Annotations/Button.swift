import UIKit

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
    
    private func setup() {
        let systemBlue = UIButton(type: .system).tintColor!
        layer.cornerRadius = 10
        layer.borderColor = systemBlue.cgColor
        layer.borderWidth = 1
        setTitleColor(.white, for: .normal)
        setTitleColor(.lightGray, for: .highlighted)
        setBackgroundColor(color: systemBlue, forState: .normal)
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: 30)
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
