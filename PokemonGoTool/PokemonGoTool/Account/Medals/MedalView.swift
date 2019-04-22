
import UIKit

enum MedalType {
    case bronze
    case silver
    case gold
    case platinum
}

class MedalView: UIView {

    @IBOutlet var medalImageView: UIImageView!
    @IBOutlet var countLabel: Label!
    @IBOutlet var descriptionLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(type: MedalType, count: Int, description: String) {
        countLabel.text = "\(count)"
        descriptionLabel.text = description
        
        switch type {
        case .bronze:
            medalImageView.image = UIImage(named: "")
        case .silver:
            medalImageView.image = UIImage(named: "")
        case .gold:
            medalImageView.image = UIImage(named: "")
        case .platinum:
            medalImageView.image = UIImage(named: "")
        }
    }
}
