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
        layer.cornerRadius = 10
        layer.borderColor = UIButton(type: .system).tintColor.cgColor
        layer.borderWidth = 1
        backgroundColor = .clear
        setBackgroundColor(color: UIColor.blue.withAlphaComponent(0.3), forState: .highlighted)

    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: 30)
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
