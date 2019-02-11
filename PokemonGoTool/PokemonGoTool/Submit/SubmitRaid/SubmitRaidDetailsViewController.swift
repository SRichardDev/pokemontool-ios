
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController, SubmitRaidDelegate {
    
    weak var coordinator: MainCoordinator?
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let raidLevelViewController = RaidLevelViewController.instantiateFromStoryboard()
    private let raidBossCollectionViewController = RaidBossCollectionViewController.instantiateFromStoryboard()
    private let hatchTimePickerViewController = RaidHatchTimePickerViewController.instantiateFromStoryboard()
    private let timeLeftPickerViewController = RaidTimeLeftPickerViewController.instantiateFromStoryboard()
    private let userParticipatesViewController = RaidUserParticipateSwitchViewController.instantiateFromStoryboard()
    private let meetupTimePickerViewController = RaidMeetupTimePickerViewController.instantiateFromStoryboard()
    private let raidAlreadyRunningSwitchViewController = RaidAlreadyRunningSwitchViewController.instantiateFromStoryboard()
    private let doneButton = Button()
    var viewModel: SubmitRaidViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviewAndEdgeConstraints(stackView,
                                          edges: .all,
                                          margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                          constrainToSafeAreaGuide: false)
        
        doneButton.setTitle("Raid melden", for: .normal)
        doneButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        let image = UIImage(named: viewModel.imageName)!
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        raidLevelViewController.viewModel = viewModel
        raidBossCollectionViewController.viewModel = viewModel
        raidAlreadyRunningSwitchViewController.viewModel = viewModel
        hatchTimePickerViewController.viewModel = viewModel
        timeLeftPickerViewController.viewModel = viewModel
        userParticipatesViewController.viewModel = viewModel
        meetupTimePickerViewController.viewModel = viewModel

        timeLeftPickerViewController.view.isVisible = viewModel.isRaidAlreadyRunning
        meetupTimePickerViewController.view.isVisible = viewModel.isUserParticipating
        
        let arenaNameLabel = Label()
        arenaNameLabel.style = 3
        arenaNameLabel.text = viewModel.arena.name
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(arenaNameLabel)
        stackView.addArrangedViewController(viewController: raidLevelViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: raidAlreadyRunningSwitchViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: raidBossCollectionViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: hatchTimePickerViewController, to: self)
        stackView.addArrangedViewController(viewController: timeLeftPickerViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: userParticipatesViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: meetupTimePickerViewController, to: self)
        stackView.addArrangedSubview(doneButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Neuer Level \(viewModel.selectedRaidLevel) Raid")
    }
    
    @objc
    func submitTapped() {
        viewModel.submitRaid()
        dismiss(animated: true)
    }
    
    func update(of type: UpdateType) {
        switch type {
        case .raidLevelChanged:
            UIView.transition(with: imageView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.imageView.image = UIImage(named: self.viewModel.imageName)!
                self.setTitle("Neuer Level \(self.viewModel.selectedRaidLevel) Raid")
            })

        case .raidAlreadyRunning:
            changeVisibiltyOf(viewControllers: [hatchTimePickerViewController,
                                                timeLeftPickerViewController])
            raidBossCollectionViewController.toggleScrolling()
        case .userParticipates:
            changeVisibility(of: meetupTimePickerViewController, visible: viewModel.isUserParticipating, hideAnimated: true)
        case .currentRaidbossesChanged:
            raidBossCollectionViewController.updateRaidBosses()
        }
    }
    
    private func changeVisibiltyOf(viewControllers: [UIViewController]) {
        
        var viewControllersToShow = [UIViewController]()
        var viewControllersToHide = [UIViewController]()

        for viewController in viewControllers {
            viewController.view.isHidden ? viewControllersToShow.append(viewController) : viewControllersToHide.append(viewController)
        }
        
        viewControllersToHide.forEach { vcToHide in
            UIView.animate(withDuration: 0.25, animations: {
                vcToHide.view.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, animations: {
                    vcToHide.view.isHidden = true
                }, completion: { _ in
                    viewControllersToShow.forEach { vcToShow in
                        UIView.animate(withDuration: 0.25, animations: {
                            vcToShow.view.alpha = 1
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.25, animations: {
                                vcToShow.view.isHidden = false
                            })
                        })
                    }
                })
            })
        }
    }
    
    private func changeVisibility(of viewController: UIViewController, visible: Bool, hideAnimated: Bool = true) {
        UIView.animate(withDuration: 0.25, animations: {
            viewController.view.alpha = visible ? 1 : 0
        }) { done in
            if hideAnimated {
                UIView.animate(withDuration: 0.25) {
                    viewController.view.isHidden = !visible
                }
            } else {
                viewController.view.isHidden = !visible
            }
        }
    }
}


