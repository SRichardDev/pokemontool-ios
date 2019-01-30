
import UIKit

class MainCoordinator: Coordinator {
    
    var children = [Coordinator]()
    var tabBarController: UITabBarController
    var navigationController = UINavigationController()
    var appModule: AppModule
    
    init(appModule: AppModule, tabBarController: UITabBarController) {
        self.appModule = appModule
        self.tabBarController = tabBarController
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    func start() {
        let mapViewController = MapViewController.instantiateFromStoryboard()
        mapViewController.coordinator = self
        mapViewController.firebaseConnector = appModule.firebaseConnector
        mapViewController.locationManager = appModule.locationManager
        
        let accountViewController = AccountViewController.instantiateFromStoryboard()
        accountViewController.coordinator = self
        accountViewController.firebaseConnector = appModule.firebaseConnector
        tabBarController.viewControllers = [mapViewController, accountViewController]
    }
    
    func showSubmitPokestopAndArena(for viewModel: SubmitViewModel) {
        let submitViewController = SubmitViewController.instantiateFromStoryboard()
        submitViewController.coordinator = self
        submitViewController.viewModel = viewModel
        navigationController.viewControllers = [submitViewController]
        tabBarController.present(navigationController, animated: true)
        
//        let feedback = UIImpactFeedbackGenerator(style: .heavy)
//        feedback.impactOccurred()
    }
    
    func showSubmitName(for viewModel: SubmitViewModel) {
        let submitNameViewController = SubmitNameViewController.instantiateFromStoryboard()
        submitNameViewController.coordinator = self
        submitNameViewController.viewModel = viewModel
        navigationController.pushViewController(submitNameViewController, animated: true)
    }
    
    func showSubmitCheck(for viewModel: SubmitViewModel) {
        let submitCheckViewController = SubmitCheckViewController.instantiateFromStoryboard()
        submitCheckViewController.coordinator = self
        submitCheckViewController.viewModel = viewModel
        navigationController.pushViewController(submitCheckViewController, animated: true)
    }
    
    func showSubmitQuest(for pokestop: Pokestop) {
        let submitQuestViewController = SubmitQuestViewController.instantiateFromStoryboard()
        submitQuestViewController.coordinator = self
        submitQuestViewController.pokestop = pokestop
        submitQuestViewController.firebaseConnector = appModule.firebaseConnector
        navigationController.viewControllers = [submitQuestViewController]
        tabBarController.present(navigationController, animated: true)
    }
    
    func showSubmitRaid(for arena: Arena) {
        let submitRaidDetailsViewController = SubmitRaidDetailsViewController.instantiateFromStoryboard()
        submitRaidDetailsViewController.coordinator = self
        let scrollableViewController = ScrollableViewController(childViewController: submitRaidDetailsViewController)
        navigationController.viewControllers = [scrollableViewController]
        tabBarController.present(navigationController, animated: true)
    }
}
