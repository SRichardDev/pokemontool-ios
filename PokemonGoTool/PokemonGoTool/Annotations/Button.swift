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
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        backgroundColor = .clear
        titleLabel?.textColor = .black
        titleLabel?.tintColor = .black
        setTitleColor(.black, for: .normal)
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: 30)
        }
    }
}
