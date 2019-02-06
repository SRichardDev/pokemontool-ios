
import UIKit

class RaidBossCollectionViewController: UIViewController, StoryboardInitialViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    private var scrollTimer: Timer?
    private var newOffsetX: CGFloat = 0.0
    private var reverseScrolling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
        collectionView.isUserInteractionEnabled = viewModel.isRaidAlreadyRunning
    }

    func updateRaidBosses() {
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func toggleScrolling() {
        if viewModel.isRaidAlreadyRunning {
            startTimer()
            titleLabel.text = "Mögliche Raidbosse:"
            collectionView.isUserInteractionEnabled = false
        } else {
            scrollTimer?.invalidate()
            titleLabel.text = "Wähle den Raidboss aus:"
            collectionView.isUserInteractionEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? RaidBossCell else { return }
        viewModel.selectedRaidBoss = cell.titleLabel.text ?? "?"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentRaidBosses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RaidBossCell
        cell.titleLabel.text = viewModel.currentRaidBosses[indexPath.row][1]
        cell.imageView.image = ImageManager.image(named: viewModel.currentRaidBosses[indexPath.row][0])?.colorized(with: .black)
        return cell
    }
    
    private func startTimer() {
        scrollTimer = Timer(fire: Date(), interval: 0.015, repeats: true) { (timer) in
            let initailPoint = CGPoint(x: self.newOffsetX,y :0)
            
            if __CGPointEqualToPoint(initailPoint, self.collectionView.contentOffset) {
                self.reverseScrolling ? (self.newOffsetX -= 1) : (self.newOffsetX += 1)
                let reachedRightEnd = self.newOffsetX > self.collectionView.contentSize.width - self.collectionView.frame.size.width
                let reachedLeftEnd = self.newOffsetX < 0

                if reachedRightEnd {
                    self.reverseScrolling = true
                } else if reachedLeftEnd {
                    self.reverseScrolling = false
                }
                self.collectionView.contentOffset = CGPoint(x: self.newOffsetX,y :0)
            } else {
                self.newOffsetX = self.collectionView.contentOffset.x
            }
        }
        RunLoop.current.add(scrollTimer!, forMode: .common)
    }
}


class RaidBossCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                if self.isSelected {
                    self.layer.borderColor = UIColor.lightGray.cgColor
                    self.layer.borderWidth = 1
                    self.layer.cornerRadius = 5
                } else {
                    self.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
    }
}
