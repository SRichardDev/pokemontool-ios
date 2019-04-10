
import UIKit

@IBDesignable
class StackView: UIStackView {

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
    
    private func setup() {
        axis = .vertical
        spacing = 20
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addToView(_ view: UIView) {
        view.addSubviewAndEdgeConstraints(self,
                                          edges: .all,
                                          margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                          constrainToSafeAreaGuide: false)
    }
}
