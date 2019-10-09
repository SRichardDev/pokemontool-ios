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
    
    private func setup() {
        layer.borderWidth = 1
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        layer.cornerRadius = 10
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: 44)
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    override open var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        if isEnabled {
        } else {
        }
    }
}
