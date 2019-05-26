
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
        
//        let backgroundView = UIView()
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.backgroundColor = .orange
//        backgroundView.layer.cornerRadius = 10
//        addSubview(backgroundView)
//        sendSubviewToBack(backgroundView)
//        NSLayoutConstraint.activate([leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 10),
//                                     rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -10),
//                                     topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
//                                     bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)])
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
        spacing = 15
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
        
//        let backgroundView = UIView()
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.backgroundColor = UIColor.random()
//        backgroundView.layer.cornerRadius = 10
//        backgroundView.layer.borderColor = UIColor.lightGray.cgColor
//        backgroundView.layer.borderWidth = 2
//        addSubview(backgroundView)
//        sendSubviewToBack(backgroundView)
//        NSLayoutConstraint.activate([leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 10),
//                                     rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -10),
//                                     topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
//                                     bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)])
    }
}
