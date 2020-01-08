
import UIKit

enum CircleButtonType {
    case accept
    case cancel
    case map
}

class CircleButton: UIButton {
    
    var type: CircleButtonType = .accept {
        didSet {
            setup()
        }
    }
    
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
        setup()
    }
    
    private func setup() {

        switch type {
        case .accept:
            backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            setBackgroundImage(ImageManager.systemImage(type: .checkMark), for: .normal)
        case .cancel:
            backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            setBackgroundImage(ImageManager.systemImage(type: .xMark), for: .normal)
        case .map:
            backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            setBackgroundImage(ImageManager.systemImage(type: .map), for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: 60, height: 60)
        }
    }
}
