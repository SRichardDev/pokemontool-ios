
import UIKit

class MapCrosshair: UIView {
    
    var crossHairImageView: UIImageView!
    var backgroundCrossHairImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        isUserInteractionEnabled = false
        backgroundCrossHairImageView = UIImageView(image: UIImage(named: "CrosshairRed"))
        backgroundCrossHairImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundCrossHairImageView.alpha = 0
        addSubview(backgroundCrossHairImageView)

        crossHairImageView = UIImageView(image: UIImage(named: "Crosshair"))
        crossHairImageView.translatesAutoresizingMaskIntoConstraints = false
        crossHairImageView.alpha = 0
        addSubview(crossHairImageView)
        
        NSLayoutConstraint.activate([backgroundCrossHairImageView.leftAnchor.constraint(equalTo: leftAnchor),
                                     backgroundCrossHairImageView.rightAnchor.constraint(equalTo: rightAnchor),
                                     backgroundCrossHairImageView.topAnchor.constraint(equalTo: topAnchor),
                                     backgroundCrossHairImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     crossHairImageView.leftAnchor.constraint(equalTo: leftAnchor),
                                     crossHairImageView.rightAnchor.constraint(equalTo: rightAnchor),
                                     crossHairImageView.topAnchor.constraint(equalTo: topAnchor),
                                     crossHairImageView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    func startAnimating() {
        transform = CGAffineTransform(scaleX: 100, y: 100)

        backgroundCrossHairImageView.flash(animation: .opacity)
        UIView.animate(withDuration: 0.5) {
            self.crossHairImageView.alpha = 1
            self.transform = CGAffineTransform.identity
        }
    }
    
    func stopAnimating() {
        backgroundCrossHairImageView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.25) {
            self.crossHairImageView.alpha = 0
        }
    }
}
