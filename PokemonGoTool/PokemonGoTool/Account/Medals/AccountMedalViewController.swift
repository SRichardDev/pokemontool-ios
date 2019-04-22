
import UIKit

class AccountMedalViewController: UIViewController, StoryboardInitialViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let width = (view.frame.size.width - 52) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: layout.itemSize.height)
        
        let size = collectionView.collectionViewLayout.collectionViewContentSize
        heightConstraint.constant = size.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
}

extension AccountMedalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "medalCell", for: indexPath) as! MedalCollectionViewCell
        cell.setup()
        return cell
    }
}

class MedalCollectionViewCell: UICollectionViewCell {

    @IBOutlet var medalImageView: UIImageView!
    @IBOutlet var countLabel: Label!
    @IBOutlet var descriptionLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {

    }
}
