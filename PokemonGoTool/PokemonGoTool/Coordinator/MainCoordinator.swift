
import UIKit
import NVActivityIndicatorView
import UIWindowTransitions

class MainCoordinator: Coordinator, FirebaseStartupDelegate {
    
    var children = [Coordinator]()
    var tabBarController = UITabBarController()
    var navigationController = NavigationController()
    let mainNavigationController = UINavigationController()
    var appModule: AppModule
    var window: UIWindow!
    
    init(appModule: AppModule, window: UIWindow) {
        self.appModule = appModule
        self.window = window
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        let loadingViewController = LoadingViewController.fromStoryboard()
        window.rootViewController = loadingViewController
        appModule.firebaseConnector.startUpDelegate = self
    }
    
    func didLoadInitialData() {
        showMainMap()
    }

    func showMainMap() {
        let mapViewController = MapViewController.fromStoryboard()
        mapViewController.coordinator = self
        mapViewController.firebaseConnector = appModule.firebaseConnector
        mapViewController.locationManager = appModule.locationManager
        mapViewController.tabBarItem = UITabBarItem(title: "Karte", image: UIImage(named: "Map"), selectedImage: nil)
        
        let accountViewController = AccountViewController.fromStoryboard()
        let scrollableViewController = ScrollableViewController(childViewController: accountViewController)
        scrollableViewController.title = "Account"
        scrollableViewController.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "Account"), selectedImage: nil)
        accountViewController.coordinator = self
        let viewModel = AccountViewModel(firebaseConnector: appModule.firebaseConnector)
        accountViewController.viewModel = viewModel
        mainNavigationController.navigationBar.prefersLargeTitles = true
        mainNavigationController.viewControllers = [scrollableViewController]
        tabBarController.viewControllers = [mapViewController, mainNavigationController]
        window.rootViewController = tabBarController
        
        var options = UIWindow.TransitionOptions()
        options.direction = .fade
        options.duration = 0.75
        options.style = .easeOut
        window.setRootViewController(tabBarController, options: options)
    }
    
    func showSubmitPokestopAndArena(for viewModel: SubmitViewModel) {
        let submitViewController = SubmitViewController.fromStoryboard()
        submitViewController.coordinator = self
        submitViewController.viewModel = viewModel
        navigationController.viewControllers = [submitViewController]
        tabBarController.present(navigationController, animated: true)
        impact()
    }
    
    func showSubmitName(for viewModel: SubmitViewModel) {
        let submitNameViewController = SubmitNameViewController.fromStoryboard()
        submitNameViewController.coordinator = self
        submitNameViewController.viewModel = viewModel
        navigationController.pushViewController(submitNameViewController, animated: true)
        impact()
    }
    
    func showSubmitCheck(for viewModel: SubmitViewModel) {
        let submitCheckViewController = SubmitCheckViewController.fromStoryboard()
        submitCheckViewController.coordinator = self
        submitCheckViewController.viewModel = viewModel
        navigationController.pushViewController(submitCheckViewController, animated: true)
        impact()
    }
    
    func showSubmitQuest(for pokestop: Pokestop) {
        let submitQuestViewController = SubmitQuestViewController.fromStoryboard()
        submitQuestViewController.coordinator = self
        submitQuestViewController.pokestop = pokestop
        submitQuestViewController.firebaseConnector = appModule.firebaseConnector
        navigationController.viewControllers = [submitQuestViewController]
        tabBarController.present(navigationController, animated: true)
        impact()
    }
    
    func showSubmitRaid(for arena: Arena) {
        let submitRaidDetailsViewController = SubmitRaidDetailsViewController.fromStoryboard()
        submitRaidDetailsViewController.viewModel = SubmitRaidViewModel(arena: arena,
                                                                        firebaseConnector: appModule.firebaseConnector)
        submitRaidDetailsViewController.coordinator = self
        submitRaidDetailsViewController.firebaseConnector = appModule.firebaseConnector
        embedInScrollViewControllerAndPresent(viewController: submitRaidDetailsViewController)
    }
    
    func showPokestopDetails(for pokestop: Pokestop) {
        let pokestopDetailsViewController = PokestopDetailsViewController.fromStoryboard()
        pokestopDetailsViewController.coordinator = self
        pokestopDetailsViewController.viewModel = PokestopDetailsViewModel(pokestop: pokestop,
                                                                           firebaseConnector: appModule.firebaseConnector)
        embedInScrollViewControllerAndPresent(viewController: pokestopDetailsViewController)
    }
    
    func showArenaDetails(for arena: Arena) {
        let arenaDetailsViewController = ArenaDetailsViewController.fromStoryboard()
        arenaDetailsViewController.coordinator = self
        arenaDetailsViewController.viewModel = ArenaDetailsViewModel(arena: arena,
                                                                     firebaseConnector: appModule.firebaseConnector)
        embedInScrollViewControllerAndPresent(viewController: arenaDetailsViewController)
    }

    func showRaidParticipants(_ viewModel: ArenaDetailsViewModel) {
        let participantsTableViewController = ArenaDetailsParticipantsTableViewController.fromStoryboard()
        participantsTableViewController.viewModel = viewModel
        navigationController.pushViewController(participantsTableViewController, animated: true)
        impact()
    }

    func showRaidChat(_ viewModel: ArenaDetailsViewModel) {
        let chatViewController = ChatViewController.fromStoryboard()
        chatViewController.viewModel = viewModel
        chatViewController.firebaseConnector = appModule.firebaseConnector
        navigationController.pushViewController(chatViewController, animated: true)
        impact()
    }
    
    func showTeamAndLevel(signUpViewModel: SignUpViewModel? = nil, accountViewModel: AccountViewModel? = nil) {
        let accountDetailsViewController = AccountTeamAndLevelViewController.fromStoryboard()
        accountDetailsViewController.signUpViewModel = signUpViewModel
        accountDetailsViewController.accountViewModel = accountViewModel
        accountDetailsViewController.coordinator = self
        mainNavigationController.pushViewController(accountDetailsViewController, animated: true)
        impact()
    }
    
    func showAccountInput(_ viewModel: SignUpViewModel? = nil, type: AccountInputType) {
        let inputViewController = AccountInputViewController.fromStoryboard()
        inputViewController.viewModel = viewModel ?? SignUpViewModel(firebaseConnector: appModule.firebaseConnector)
        inputViewController.coordinator = self
        inputViewController.type = type
        mainNavigationController.pushViewController(inputViewController, animated: true)
        impact()
    }
    
    func showSignUp(_ viewModel: SignUpViewModel) {
        let signUpViewController = AccountSignUpViewController.fromStoryboard()
        signUpViewController.viewModel = viewModel
        signUpViewController.coordinator = self
        mainNavigationController.pushViewController(signUpViewController, animated: true)
        impact()
    }
    
    private func embedInScrollViewControllerAndPresent(viewController: UIViewController) {
        let scrollableViewController = ScrollableViewController(childViewController: viewController)
        navigationController.viewControllers = [scrollableViewController]
        tabBarController.present(navigationController, animated: true)
        impact()
    }
    
    private func impact() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
    }
}
