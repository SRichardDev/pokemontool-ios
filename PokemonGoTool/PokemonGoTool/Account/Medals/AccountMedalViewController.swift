
import UIKit

class AccountMedalViewController: UIViewController, StoryboardInitialViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension AccountMedalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MedalCollectionViewCell
        cell.setup()
        return cell
    }
}

class MedalCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var medalView: MedalView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        medalView.setup(type: .gold, count: 123, description: "Foobar lol")
    }
}
