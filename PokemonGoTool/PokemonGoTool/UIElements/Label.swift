
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
                textColor = .black
            } else if style == 1 {
                textColor = .lightGray
//                font = UIFont.systemFont(ofSize: 12, weight: .medium)
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
