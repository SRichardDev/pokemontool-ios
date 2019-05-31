
import UIKit

class AccountMedalViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountMedalViewModel!
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Medallien:"
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let width = (collectionView.bounds.size.width - 25) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 150)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = collectionView.collectionViewLayout.collectionViewContentSize
        heightConstraint.constant = size.height
    }
}

extension AccountMedalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.medals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "medalCell", for: indexPath) as! MedalCollectionViewCell
        let medal = viewModel.medals[indexPath.row]
        cell.setup(with: medal)
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
    
    func setup(with medal: Medal) {
        medalImageView.image = medal.image
        countLabel.text = "\(medal.count)"
        descriptionLabel.text = medal.description
    }
}
