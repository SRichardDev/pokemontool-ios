
import UIKit

@IBDesignable
class OuterVerticalStackView: UIStackView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        axis = .vertical
        spacing = 30
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addToView(_ view: UIView) {
        view.addSubviewAndEdgeConstraints(self,
                                          edges: .all,
                                          margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                          constrainToSafeAreaGuide: true)
    }
}

class InnerVerticalStackView: OuterVerticalStackView {
    
    override func setup() {
        axis = .vertical
        spacing = 10
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
    }
}
