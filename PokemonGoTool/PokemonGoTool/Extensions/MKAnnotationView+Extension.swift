
import MapKit

extension MKAnnotationView {
    func addPulsator(numPulses: Int, color: UIColor = .orange) {
        let pulsator = Pulsator()
        pulsator.radius = 40.0
        pulsator.position = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        pulsator.numPulse = numPulses
        pulsator.zPosition = -1
        pulsator.backgroundColor = color.cgColor
        pulsator.autoRemove = true
        layer.addSublayer(pulsator)
        pulsator.start()
    }
    
    func addParticipantsCountBadge(_ count: Int) {
        let badgeLabel = UILabel(badgeText: "\(count)")
        addSubview(badgeLabel)
        badgeLabel.leftAnchor.constraint(equalTo: rightAnchor, constant: -7).isActive = true
        badgeLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
    }
}


fileprivate extension UILabel {
    convenience init(badgeText: String, color: UIColor = .red, fontSize: CGFloat = UIFont.smallSystemFontSize) {
        self.init()
        text = badgeText.count > 1 ? " \(badgeText) " : badgeText
        textAlignment = .center
        textColor = .white
        backgroundColor = color
        
        font = UIFont.systemFont(ofSize: fontSize)
        layer.cornerRadius = fontSize * CGFloat(0.6)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .width,
                                         relatedBy: .greaterThanOrEqual,
                                         toItem: self,
                                         attribute: .height,
                                         multiplier: 1,
                                         constant: 0))
    }
}
