
import UIKit

class MessageView: UIView {
    
    private let label = Label()
    private var topConstraint: NSLayoutConstraint?
    
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
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        backgroundColor = .red
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        addSubviewAndEdgeConstraints(label, margins: UIEdgeInsets(top: 2, left: 15, bottom: 2, right: 15))
        label.text = "Filter aktiv"
        label.textColor = .white
        addShadow()
    }
    
    func addToTopMiddle(in view: UIView) {
        view.addSubview(self)
        view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.topAnchor, constant: -5).isActive = true
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    func show() {
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25) { self.alpha = 0 }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
