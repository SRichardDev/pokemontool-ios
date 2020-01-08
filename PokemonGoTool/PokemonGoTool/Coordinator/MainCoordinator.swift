
import UIKit
import NVActivityIndicatorView
import UIWindowTransitions
import NSTAppKit

class MainCoordinator: Coordinator, FirebaseStartupDelegate {
    
    var children = [Coordinator]()
    var tabBarController = UITabBarController()
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
        mapViewController.tabBarItem = UITabBarItem(title: "Karte",
                                                    image: UIImage(systemName: "map"),
                                                    selectedImage: nil)
        
        let accountViewController = AccountViewController.fromStoryboard()
        let scrollableViewController = ScrollableViewController(childViewController: accountViewController)
        scrollableViewController.title = "Account"
        scrollableViewController.tabBarItem = UITabBarItem(title: "Account",
                                                           image: UIImage(systemName: "person.circle"),
                                                           selectedImage: nil)
        accountViewController.coordinator = self
        let viewModel = AccountViewModel(firebaseConnector: appModule.firebaseConnector)
        accountViewController.viewModel = viewModel
        mainNavigationController.navigationBar.prefersLargeTitles = true
        mainNavigationController.viewControllers = [scrollableViewController]
        tabBarController.viewControllers = [mapViewController, mainNavigationController]
        if !appModule.firebaseConnector.isSignedIn { tabBarController.selectedIndex = 1 }
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
        let navigationController = NavigationController()
        navigationController.viewControllers = [submitViewController]
        tabBarController.present(navigationController, animated: true)
        impact()
    }
    
    func showSubmitName(for viewModel: SubmitViewModel, in navigationController: UINavigationController) {
        let submitNameViewController = SubmitNameViewController.fromStoryboard()
        submitNameViewController.coordinator = self
        submitNameViewController.viewModel = viewModel
        navigationController.pushViewController(submitNameViewController, animated: true)
        impact()
    }
    
    func showSubmitCheck(for viewModel: SubmitViewModel, in navigationController: UINavigationController) {
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
        let navigationController = NavigationController()
        navigationController.viewControllers = [submitQuestViewController]
        tabBarController.present(navigationController, animated: true)
        impact()
    }
    
    func showSubmitRaid(for arena: Arena) {
        let submitRaidDetailsViewController = SubmitRaidDetailsViewController.fromStoryboard()
        submitRaidDetailsViewController.viewModel = SubmitRaidViewModel(arena: arena,
                                                                        firebaseConnector: appModule.firebaseConnector)        
        let navigationController = NavigationController()
        navigationController.viewControllers = [submitRaidDetailsViewController]
        tabBarController.present(navigationController, animated: true)
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
        let navigationController = NavigationController()
        navigationController.viewControllers = [arenaDetailsViewController]
        tabBarController.present(navigationController, animated: true)
    }

    func showRaidParticipants(_ viewModel: ArenaDetailsViewModel, in navigationController: UINavigationController) {
        let participantsTableViewController = ArenaDetailsParticipantsTableViewController.fromStoryboard()
        participantsTableViewController.viewModel = viewModel
        navigationController.pushViewController(participantsTableViewController, animated: true)
        impact()
    }

    func showRaidChat(_ viewModel: ArenaDetailsViewModel, in navigationController: UINavigationController) {
        let chatViewController = ChatViewController.fromStoryboard()
        chatViewController.viewModel = viewModel
        chatViewController.firebaseConnector = appModule.firebaseConnector
        navigationController.pushViewController(chatViewController, animated: true)
        impact()
    }
    
    func showAccountDetails(viewModel: AccountViewModel) {
        let accountDetailsViewController = AccountDetailsViewController.fromStoryboard()
        accountDetailsViewController.viewModel = viewModel
        let scrollableViewController = ScrollableViewController(childViewController: accountDetailsViewController)
        scrollableViewController.title = "Account Details"
        mainNavigationController.pushViewController(scrollableViewController, animated: true)
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
    
    func showMapFilter() {
        let mapFilterViewController = MapFilterViewController.fromStoryboard()
        let scrollableViewController = ScrollableViewController(childViewController: mapFilterViewController)
        let navigationController = NavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.viewControllers = [scrollableViewController]
        tabBarController.present(navigationController, animated: true)
        impact()
    }
    
    func showPokemonSelection(viewModel: ArenaDetailsViewModel) {
//        let pokemonTableViewController = PokemonTableViewController.fromStoryboard()
//        pokemonTableViewController.viewModel = viewModel
//        navigationController.pushViewController(pokemonTableViewController, animated: true)
//        impact()
    }
    
    private func embedInScrollViewControllerAndPresent(viewController: UIViewController) {
        let scrollableViewController = ScrollableViewController(childViewController: viewController)
        let navigationController = NavigationController()
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
