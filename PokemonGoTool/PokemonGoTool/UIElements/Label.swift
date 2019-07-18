
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
            } else if style == 4 {
                textColor = .black
                font = UIFont.systemFont(ofSize: 15, weight: .regular)
            } else if style == 5 {
                textColor = .gray
                font = UIFont.systemFont(ofSize: 12, weight: .regular)
            } else if style == 6 {
                textColor = .black
                font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            } else if style == 7 {
                textColor = .black
                font = UIFont.boldSystemFont(ofSize: 34)
            } else if style == 8 {
                textColor = .red
                font = UIFont.systemFont(ofSize: 12, weight: .regular)
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
