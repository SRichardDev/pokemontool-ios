
import UIKit

class StackView: UIStackView {

    override func awakeFromNib() {
        super.awakeFromNib()
        axis = .vertical
        spacing = 20
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
    }
}
