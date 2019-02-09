
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
                font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            } else if style == 1 {
                textColor = .lightGray
                font = UIFont.systemFont(ofSize: 12, weight: .regular)
            } else if style == 2 {
                textColor = .black
                font = UIFont.systemFont(ofSize: 25, weight: .semibold)
            } else if style == 3 {
                textColor = .black
                font = UIFont.systemFont(ofSize: 25, weight: .semibold)
                textAlignment = .center
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
