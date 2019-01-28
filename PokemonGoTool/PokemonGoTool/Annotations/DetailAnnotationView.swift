
import UIKit

class DetailAnnotationView: UIView {
    
    @IBOutlet weak var annotationImageView: UIImageView!
    @IBOutlet weak var annotationNameLabel: UILabel!
    @IBOutlet weak var annotationInfoLabel: UILabel!
    
    var annotation: Annotation!
    var raidDetails: [String] = []
    weak var delegate: DetailAnnotationViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
    }
    
    func configure(with annotation: Annotation) {
        self.annotation = annotation
        annotationNameLabel.text = annotation.name
        
        if let _ = annotation as? Pokestop {
            annotationImageView.image = UIImage(named: "Pokestop")
        } else if let _ = annotation as? Arena {
            annotationImageView.image = UIImage(named: "arena")
        }
    }
    
    @IBAction func showAnnotationInfoTapped(_ sender: Any) {
        delegate?.showDetail(for: annotation)
    }
}
