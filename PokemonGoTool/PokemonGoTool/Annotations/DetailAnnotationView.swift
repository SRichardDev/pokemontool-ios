
import UIKit

class DetailAnnotationView: UIView {
    
    @IBOutlet private var annotationImageView: UIImageView!
    @IBOutlet private var annotationNameLabel: UILabel!
    @IBOutlet private var annotationInfoLabel: UILabel!
    @IBOutlet private var buttonsStackView: UIStackView!
    
    var annotation: Annotation!
    var raidDetails: [String] = []
    weak var delegate: DetailAnnotationViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
    }
    
    func configure(with annotation: Annotation) {
        self.annotation = annotation
        annotationNameLabel.text = annotation.name
        
        if let _ = annotation as? Pokestop {
            annotationImageView.image = UIImage(named: "Pokestop")
            let questButton = Button()
            let detailsButton = Button()
            questButton.setTitle("Neue Quest", for: .normal)
            questButton.addTarget(self, action: #selector(DetailAnnotationView.showAnnotationInfoTapped(_:)), for: .touchUpInside)
            detailsButton.setTitle("Details", for: .normal)
            buttonsStackView.addArrangedSubview(questButton)
            buttonsStackView.addArrangedSubview(detailsButton)
        } else if let _ = annotation as? Arena {
            annotationImageView.image = UIImage(named: "arena")
            let raidButton = Button()
            let detailsButton = Button()
            raidButton.setTitle("Neuer Raid", for: .normal)
            detailsButton.setTitle("Details", for: .normal)
            buttonsStackView.addArrangedSubview(raidButton)
            buttonsStackView.addArrangedSubview(detailsButton)
        }
    }
    
    @objc func showAnnotationInfoTapped(_ sender: Any) {
        delegate?.showDetail(for: annotation)
    }
}
