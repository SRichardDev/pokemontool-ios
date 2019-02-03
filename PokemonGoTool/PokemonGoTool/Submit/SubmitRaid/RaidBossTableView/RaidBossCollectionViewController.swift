
import UIKit

class RaidBossCollectionViewController: UIViewController, StoryboardInitialViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        startTimer()
    }

    func update() {
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentRaidBosses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RaidBossCell
        cell.titleLabel.text = viewModel.currentRaidBosses[indexPath.row][1]
        cell.imageView.image = ImageManager.image(named: viewModel.currentRaidBosses[indexPath.row][0])
        return cell
    }
    
    var carousalTimer: Timer?
    var newOffsetX: CGFloat = 0.0
    var reverse = false
    func startTimer() {
        carousalTimer = Timer(fire: Date(), interval: 0.015, repeats: true) { (timer) in
            let initailPoint = CGPoint(x: self.newOffsetX,y :0)
            
            if __CGPointEqualToPoint(initailPoint, self.collectionView.contentOffset) {
                self.reverse ? (self.newOffsetX -= 1) : (self.newOffsetX += 1)
                let reachedRightEnd = self.newOffsetX > self.collectionView.contentSize.width - self.collectionView.frame.size.width
                let reachedLeftEnd = self.newOffsetX < 0

                if reachedRightEnd {
                    self.reverse = true
                } else if reachedLeftEnd {
                    self.reverse = false
                }
                
                self.collectionView.contentOffset = CGPoint(x: self.newOffsetX,y :0)
                
            } else {
                self.newOffsetX = self.collectionView.contentOffset.x
            }
        }
        
        RunLoop.current.add(carousalTimer!, forMode: .common)
    }
}

class RaidBossCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: Label!
}
