
import UIKit

class RaidBossCollectionViewController: UIViewController, StoryboardInitialViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var titleLabel: Label!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var selectButton: Button!
    private var scrollTimer: Timer?
    private var newOffsetX: CGFloat = 0.0
    private var reverseScrolling = false
    var selectedRaidboss: RaidbossDefinition?
    var selectedRaidbossCallback: ((RaidbossDefinition) -> ())?
    
    var level = 3 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var isRaidRunning = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var currentRaidBosses: [RaidbossDefinition] {
        get {
            return RaidbossManager.shared.raidbosses?.filter { Int($0.level) == level } ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        activateOverViewMode()
        selectButton.isHidden = true
    }

    func updateRaidBosses() {
        collectionView.reloadData()
//        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func activateOverViewMode() {
        isRaidRunning = false
        UIView.animate(withDuration: 0.25) { self.selectButton.isHidden = true }
        startScrolling()
        titleLabel.text = "Mögliche Raidbosse:"
    }
    
    func activateSelectionMode() {
        isRaidRunning = true
        UIView.animate(withDuration: 0.25) { self.selectButton.isHidden = false }
        scrollTimer?.invalidate()
        titleLabel.text = "Wähle den Raidboss aus:"
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRaidboss = currentRaidBosses[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentRaidBosses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RaidBossCell
        cell.titleLabel.text = currentRaidBosses[indexPath.row].name
        cell.imageView.image = currentRaidBosses[indexPath.row].image
        cell.isUserInteractionEnabled = isRaidRunning
        return cell
    }
    
    private func startScrolling() {
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
        guard let scrollTimer = scrollTimer else { return }
        RunLoop.current.add(scrollTimer, forMode: .common)
    }
    
    @IBAction func didTapSelectRaidboss(_ sender: Any) {
        guard let selectedRaidbossCallback = selectedRaidbossCallback else { return }
        guard let raidboss = selectedRaidboss else { return }
        selectedRaidbossCallback(raidboss)
    }
}


class RaidBossCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                if self.isSelected {
                    self.layer.borderColor = UIColor.lightGray.cgColor
                    self.layer.borderWidth = 1

                } else {
                    self.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
    }
}
