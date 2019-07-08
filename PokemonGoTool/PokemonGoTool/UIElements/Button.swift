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
            let systemBlue = UIButton(type: .system).tintColor!
            backgroundColor = isHighlighted ? systemBlue.withAlphaComponent(0.8) : systemBlue
        } else {
            backgroundColor = .lightGray
        }
    }
}
