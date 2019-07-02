
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
        spacing = 50
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
                                          margins: UIEdgeInsets(top: 40, left: 25, bottom: 25, right: 25),
                                          constrainToSafeAreaGuide: true)
    }
}

class InnerVerticalStackView: OuterVerticalStackView {
    
    override func setup() {
        axis = .vertical
        spacing = 15
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundView = UIView()
        backgroundView.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundView.layer.shadowRadius = 0.2
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        backgroundView.layer.borderWidth = 1
        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        NSLayoutConstraint.activate([leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 7),
                                     rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -7),
                                     topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 7),
                                     bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -7)])
    }
}
